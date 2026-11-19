# Simulate the random-dot motion dataset used in Part 1.
#
# Design (per participant): instruction (accuracy, speed) x coherence
# (6.4%, 12.8%, 25.6%) x direction (left, right), 50 trials per cell = 600 trials.
# The upper boundary is the "right" response.
#
# True model, per participant:
#   drift      v = k * coherence, positive for rightward motion, negative for leftward
#   boundary   a = a_accuracy in accuracy blocks, a_speed in speed blocks
#   start      z (relative), the same in both blocks
#   non-decision time t0, the same in both blocks
# Only the boundary depends on the instruction, and only the drift depends on
# coherence ("selective influence"). The values are illustrative, chosen to give
# accuracies and RTs in the usual range for this task; they are not estimates
# from real data.
#
# Run from the book's root folder: source("data-raw/simulate_rdm.R")
# Needs the rtdists package (readers of the book do not).

library(rtdists)
set.seed(2025)

n_people <- 20
n_per_cell <- 50
coherences <- c(0.064, 0.128, 0.256)

truth <- data.frame(
  participant = sprintf("P%02d", 1:n_people),
  k           = round(exp(rnorm(n_people, log(6), 0.2)), 3),     # drift per unit coherence
  a_accuracy  = round(exp(rnorm(n_people, log(1.6), 0.12)), 3),
  a_speed     = NA,
  z           = round(plogis(rnorm(n_people, 0, 0.1)), 3),
  t0          = round(runif(n_people, 0.30, 0.40), 3)
)
truth$a_speed <- round(truth$a_accuracy * exp(rnorm(n_people, log(0.58), 0.08)), 3)

design <- expand.grid(rep = 1:n_per_cell, direction = c("left", "right"),
                      coherence = coherences, instruction = c("accuracy", "speed"),
                      stringsAsFactors = FALSE)

trials <- do.call(rbind, lapply(seq_len(n_people), function(i) {
  p <- truth[i, ]
  d <- design[sample(nrow(design)), ]                 # shuffle within the session
  d <- d[order(d$instruction == "speed"), ]           # accuracy blocks first, then speed
  v <- p$k * d$coherence * ifelse(d$direction == "right", 1, -1)
  a <- ifelse(d$instruction == "accuracy", p$a_accuracy, p$a_speed)
  s <- rdiffusion(nrow(d), a = a, v = v, t0 = p$t0, z = p$z * a)
  data.frame(participant = p$participant,
             trial       = seq_len(nrow(d)),
             instruction = d$instruction,
             coherence   = d$coherence,
             direction   = d$direction,
             response    = ifelse(s$response == "upper", "right", "left"),
             rt          = round(s$rt, 4))
}))
trials$correct <- as.integer(trials$response == trials$direction)

write.csv(trials, "data/rdm.csv", row.names = FALSE)
write.csv(truth, "data/rdm_truth.csv", row.names = FALSE)
