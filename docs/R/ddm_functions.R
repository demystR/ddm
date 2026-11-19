# Drift diffusion model functions built in this book.
#
# Every function here is derived in a chapter; this file collects them so later
# chapters (and your own scripts) can load them with
#   source("R/ddm_functions.R")
# Only base R is needed.
#
# Conventions: noise sigma = 1; time in seconds; z is the RELATIVE starting
# point (0 = lower boundary, 1 = upper boundary); the upper boundary is coded
# upper = TRUE.


# Formulas for choices and mean RT (Chapter "What the Model Predicts") --------

# Probability of reaching the upper boundary.
p_upper <- function(v, a, z) {
  if (abs(v) < 1e-8) return(z)   # with no drift, P(upper) equals the starting fraction
  (1 - exp(-2 * v * a * z)) / (1 - exp(-2 * v * a))
}

# Mean decision time for an unbiased start (z = 0.5).
mean_dt <- function(v, a) {
  if (abs(v) < 1e-8) return(a^2 / 4)
  a / (2 * v) * tanh(a * v / 2)
}


# Simulating by time steps (Chapter "One Step at a Time") ---------------------

# Simulate one trial step by step (dt in seconds).
simulate_ddm_trial <- function(v, a, z, t0, dt = 0.001, sigma = 1, keep_path = FALSE) {
  x <- z * a
  t <- 0
  path <- x
  while (x > 0 && x < a) {
    x <- x + v * dt + sigma * sqrt(dt) * rnorm(1)
    t <- t + dt
    if (keep_path) path <- c(path, x)
  }
  list(upper = x >= a, rt = t0 + t, path = path)
}

# Simulate n trials in parallel, one time step at a time. Returns each trial's
# decision time and boundary, and the paths of the first `keep` trials.
simulate_paths <- function(n, v, a, z, dt = 0.001, max_t = 4, keep = 200) {
  n_steps <- round(max_t / dt)
  x     <- rep(z * a, n)
  done  <- rep(FALSE, n)
  dtime <- rep(NA_real_, n)
  upper <- rep(NA, n)
  paths <- matrix(NA_real_, n_steps + 1, keep)
  paths[1, ] <- z * a
  for (s in seq_len(n_steps)) {
    i <- which(!done)
    if (length(i) == 0) break
    x[i] <- x[i] + v * dt + sqrt(dt) * rnorm(length(i))
    k <- i[i <= keep]
    paths[s + 1, k] <- x[k]
    hit <- i[x[i] >= a | x[i] <= 0]
    upper[hit] <- x[hit] >= a
    dtime[hit] <- s * dt
    done[hit]  <- TRUE
  }
  list(dtime = dtime, upper = upper, paths = paths, dt = dt)
}


# The first-passage time density (Chapter "From Paths to Distributions") ------

# Density g(u | z) for a process with no drift and a boundary at 1
# (Navarro & Fuss, 2009): small-time series for u < 1, large-time otherwise.
g_std <- function(u, z, K = 10) {
  out <- numeric(length(u))               # density is effectively 0 for u near 0
  small <- u < 1 & u > 1e-8
  if (any(small)) {                       # small-time series, k = -K..K
    zz <- outer(z[small], 2 * (-K:K), "+")
    out[small] <- rowSums(zz * exp(-zz^2 / (2 * u[small]))) / sqrt(2 * pi * u[small]^3)
  }
  large <- u >= 1
  if (any(large)) {                       # large-time series, k = 1..K
    k <- 1:K
    terms <- exp(-outer(u[large], k^2) * pi^2 / 2) * sin(outer(z[large], k) * pi)
    out[large] <- pi * as.vector(terms %*% k)
  }
  out
}

# Density of each trial's response and RT. Every parameter can be given as one
# value per trial.
ddm_density <- function(rt, upper, v, a, z, t0) {
  n <- length(rt)
  upper <- rep_len(upper, n); v <- rep_len(v, n); a <- rep_len(a, n)
  z <- rep_len(z, n); t0 <- rep_len(t0, n)
  t <- rt - t0
  dens <- numeric(n)
  ok <- t > 0                             # no response is possible before t0
  vv <- ifelse(upper, -v, v)              # upper boundary: reverse the drift
  zz <- ifelse(upper, 1 - z, z)           # and mirror the starting point
  dens[ok] <- exp(-vv[ok] * a[ok] * zz[ok] - vv[ok]^2 * t[ok] / 2) / a[ok]^2 *
              g_std(t[ok] / a[ok]^2, zz[ok])
  dens
}


# Simulating datasets from the density (Chapter "Checking a Fit") -------------

# Draw n trials (response and RT) for one set of parameter values, by sampling
# from the density on a fine time grid. Much faster than simulating paths, and
# accurate to within the grid width (dt).
ddm_sample_one <- function(n, v, a, z, t0, dt = 0.0005, t_max = 6) {
  t_mid <- seq(dt / 2, t_max, by = dt)                  # centres of the time bins
  p_up  <- ddm_density(t_mid, TRUE,  v, a, z, 0) * dt   # probability of each bin
  p_lo  <- ddm_density(t_mid, FALSE, v, a, z, 0) * dt
  probs <- c(p_up, p_lo)
  pick  <- sample.int(length(probs), n, replace = TRUE, prob = probs)
  upper <- pick <= length(t_mid)
  bin   <- ifelse(upper, pick, pick - length(t_mid))
  rt    <- t0 + t_mid[bin] + runif(n, -dt / 2, dt / 2)  # spread within the bin
  data.frame(upper = upper, rt = rt)
}

# The same, with one set of parameter values per trial (vectors of length n).
ddm_sample <- function(v, a, z, t0, ...) {
  n <- max(length(v), length(a), length(z), length(t0))
  pars <- data.frame(v = rep_len(v, n), a = rep_len(a, n), z = rep_len(z, n), t0 = rep_len(t0, n))
  key <- do.call(paste, pars)
  out <- data.frame(upper = logical(n), rt = numeric(n))
  for (k in unique(key)) {
    i <- which(key == k)
    p <- pars[i[1], ]
    out[i, ] <- ddm_sample_one(length(i), p$v, p$a, p$z, p$t0, ...)
  }
  out
}


# Fitting the random-dot data (Chapter "Fitting the Model") -------------------

# Drift for each trial: one strength per coherence level, signed by direction.
make_drift <- function(v_by_coherence, coherence, direction) {
  strength <- v_by_coherence[match(coherence, c(0.064, 0.128, 0.256))]
  ifelse(direction == "right", strength, -strength)
}

loglik_rdm <- function(a, z, t0, v_by_coherence, data) {
  v <- make_drift(v_by_coherence, data$coherence, data$direction)
  sum(log(ddm_density(data$rt, data$upper, v, a, z, t0)))
}

to_natural <- function(u, min_rt) {
  c(a = exp(u[1]), z = plogis(u[2]), t0 = min_rt * plogis(u[3]),
    v_064 = u[4], v_128 = u[5], v_256 = u[6])
}

neg_loglik_u <- function(u, data) {
  p <- to_natural(u, min(data$rt))
  -loglik_rdm(p[["a"]], p[["z"]], p[["t0"]], p[4:6], data)
}

# Maximum likelihood fit from several starting points. data needs columns
# rt, upper (TRUE = "right"), coherence and direction.
fit_rdm <- function(data, n_starts = 5) {
  min_rt <- min(data$rt)
  starts <- cbind(c(log(1.5), 0, 0, 0.5, 1, 1.5),
                  replicate(n_starts - 1, c(log(runif(1, 0.8, 2.5)), rnorm(1, 0, 0.3),
                                            rnorm(1, 0, 1), runif(3, 0, 2))))
  fits <- apply(starts, 2, function(s)
    optim(s, neg_loglik_u, data = data, method = "BFGS", control = list(maxit = 1000)))
  best <- fits[[which.min(sapply(fits, `[[`, "value"))]]
  list(u = best$par, par = to_natural(best$par, min_rt), logLik = -best$value,
       converged = best$convergence == 0)
}
