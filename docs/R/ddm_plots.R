# Plotting helpers for the book's figures. These draw pictures only; nothing
# here is part of the model.

# Steps drawn as a grey drift part followed by a red noise arrow.
# t, x: times and evidence values at the end of each step (first value = start).
draw_steps <- function(t, x, dt, v, xlim, ylim, title, bounds = NULL, label_first = FALSE) {
  plot(NULL, xlim = xlim, ylim = ylim, xlab = "time (s)", ylab = "evidence X", main = title)
  if (!is.null(bounds)) abline(h = bounds, lwd = 2)
  for (k in seq_len(length(x) - 1)) {
    xd <- x[k] + v * dt
    segments(t[k], x[k], t[k + 1], xd, col = "grey40", lwd = 2)
    arrows(t[k + 1], xd, t[k + 1], x[k + 1], col = "firebrick", lwd = 2, length = 0.06)
  }
  points(t, x, pch = 19, cex = 0.8)
  if (label_first) {
    xd <- x[1] + v * dt
    text(t[1], x[1], "start", pos = 2, cex = 0.85)
    text(t[2] / 2, xd + 0.1, bquote("drift part: " * v %.% Delta * t == .(sprintf("%.2f", v * dt))),
         cex = 0.85, col = "grey30")
    text(t[2], xd + 0.01, bquote("noise part: " * sigma * sqrt(Delta * t) %.% epsilon ==
                                   .(sprintf("%.2f", x[2] - xd))), pos = 4, cex = 0.85, col = "firebrick")
    text(t[2], x[2] - 0.04, sprintf("new total = %.2f", x[2]), pos = 4, cex = 0.85)
  }
}

# One path at a given step size, with a finer reference path in grey.
draw_path <- function(p, reference, a, title, xmax = 0.8) {
  plot(NULL, xlim = c(0, xmax), ylim = c(-0.05, a + 0.1), xlab = "time (s)", ylab = "evidence X",
       main = title)
  abline(h = c(0, a), lwd = 2)
  lines(reference$t, reference$X, col = "grey80")
  lines(p$t, p$X, lwd = 1.5)
  if (p$dt > 0.005) points(p$t, p$X, pch = 19, cex = 0.5)
  mtext(sprintf("%d steps; reaches a boundary at %.0f ms", length(p$t) - 1, 1000 * max(p$t)),
        side = 3, line = 0.1, cex = 0.7)
}

# The first n of many simulated trials (from simulate_paths()): paths, end
# points for a few trials, histograms of end times for many.
draw_build_up <- function(sim, n, a, title, n_draw = 200, bw = 0.05, xmax = 1.5, h_scale = 0.3,
                          labels = c("upper", "lower")) {
  plot(NULL, xlim = c(0, xmax), ylim = c(-0.8, a + 0.8), xlab = "decision time (s)",
       ylab = "", yaxt = "n", main = title)
  axis(2, at = c(0, a), labels = c("0", "a"), las = 1)
  time <- (seq_len(nrow(sim$paths)) - 1) * sim$dt
  for (j in seq_len(min(n, n_draw))) {
    col <- if (sim$upper[j]) "steelblue" else "darkorange"
    alpha <- if (n <= 10) 0.9 else 0.12
    lines(time, pmin(pmax(sim$paths[, j], 0), a), col = adjustcolor(col, alpha))
  }
  if (n <= 10) {
    points(sim$dtime[1:n], ifelse(sim$upper[1:n], a, 0), pch = 19,
           col = ifelse(sim$upper[1:n], "steelblue", "darkorange"))
  } else {
    # Heights: proportion of all n trials per second, so both histograms
    # together have an area of 1.
    breaks <- seq(0, max(sim$dtime[1:n], na.rm = TRUE) + bw, by = bw)
    for (up in c(TRUE, FALSE)) {
      h <- hist(sim$dtime[1:n][sim$upper[1:n] == up], breaks = breaks, plot = FALSE)
      height <- h$counts / (n * bw) * h_scale
      keep <- h$counts > 0
      base <- if (up) a else 0
      sgn  <- if (up) 1 else -1
      rect(h$breaks[-length(h$breaks)][keep], base, h$breaks[-1][keep], base + sgn * height[keep],
           col = adjustcolor(if (up) "steelblue" else "darkorange", 0.6), border = "white")
    }
  }
  abline(h = c(0, a), lwd = 2)
  text(xmax, a - 0.08, labels[1], adj = 1, cex = 0.8)
  text(xmax, 0.08, labels[2], adj = 1, cex = 0.8)
}
