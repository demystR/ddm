# (APPENDIX) Appendix {-}

# The Calculus Behind The Notation {#calculus}

The main chapters use only the step equation and a few results from it. This appendix
explains the calculus notation $dX = v\,dt + \sigma\,dW$ and where the density formula of
Chapter \@ref(paths-to-distributions) comes from. You do not need it to use the model.

## Slopes And Sums

Without noise, the evidence would grow smoothly at rate $v$:

$$
\frac{dX}{dt} = v.
$$

This is a **derivative**: a slope, the limit of $\Delta X / \Delta t$ as the interval
$\Delta t$ shrinks to zero. "The slope of $X$ over time is $v$."

**Integration** goes the other way: adding up all the tiny changes gives the total,

$$
X(t) = X(0) + \int_0^t v\,ds = X(0) + v\,t.
$$

With $v = 1$ and a start of 0.6, after 0.3 s the evidence is $0.6 + 0.3 = 0.9$.
Integrating means adding up thin slices: 300 slices of 1 ms, each adding 0.001.

## Adding Noise: Sums Still Work, Slopes Do Not

With noise, add up the step equation over $T$ seconds, made of $n = T / \Delta t$ steps:

$$
X(T) = X(0) + \sum_{k=1}^{n} v\,\Delta t + \sum_{k=1}^{n} \sigma\sqrt{\Delta t}\,\varepsilon_k.
$$

- The drift sum is exactly as before: $n \times v\,\Delta t = v\,T$.
- The noise sum adds $n$ independent normal draws, each with variance
  $\sigma^2 \Delta t$. Their total is normal with variance $n \sigma^2 \Delta t =
  \sigma^2 T$.

So, ignoring the boundaries, the evidence at time $T$ is normally distributed with mean
$X(0) + v\,T$ and SD $\sigma\sqrt{T}$, whatever the step size. This adding-up of random
changes is a **stochastic integral**, and the noise part added up from 0 to $t$ is the
Wiener process $W(t)$, scaled by $\sigma$.

The slope is where it breaks. The noise part's change over one step, divided by the step
length, is

$$
\frac{\sigma\sqrt{\Delta t}\,\varepsilon}{\Delta t} = \frac{\sigma\,\varepsilon}{\sqrt{\Delta t}},
$$

which grows without limit as $\Delta t$ shrinks: its SD is about 32 per second with 1 ms
steps and 1,000 with 1 µs steps. The path never settles into a slope, however far you
zoom in. That is why the model is written as $dX = v\,dt + \sigma\,dW$, which only talks
about changes over tiny intervals, and never as $dX/dt = \dots$. Equations of this kind
are called **stochastic differential equations**.

## From Paths To Probability: The Diffusion Equation

To find *when* $X$ first reaches a boundary, it helps to stop following single paths and
follow the probability over all paths instead.

Picture a drop of ink in a channel of flowing water. Without boundaries, the probability
of where $X$ could be at time $t$ is a normal bump: it starts as a spike at $z a$, its
centre drifts at speed $v$, and it spreads out with SD $\sigma\sqrt{t}$. This spreading
and drifting obeys a partial differential equation, the **diffusion** (or
Fokker-Planck) **equation**:

$$
\frac{\partial p}{\partial t} = -v\,\frac{\partial p}{\partial x} + \frac{\sigma^2}{2}\,\frac{\partial^2 p}{\partial x^2},
$$

where $p(x, t)$ is the probability density of the evidence being at level $x$ at time
$t$. The first term shifts probability along with the drift. The second spreads it out:
it is the heat equation from physics, and noise smooths out probability in the same way
heat smooths out temperature.

## Absorbing Boundaries And The Density

The boundaries act like absorbent walls: probability that reaches 0 or $a$ is removed,
because those paths have made their response. Over time the probability left between
the walls shrinks. The rate at which it leaks out through the upper wall at time $t$ is
the upper-boundary density $f_{\text{upper}}(t)$, and likewise for the lower wall. These
are the curves of Chapter \@ref(paths-to-distributions), and the limits that the
histograms of simulated paths approach.

Solving the heat equation between two absorbing walls is a classic problem with two
standard solutions, which are the two series in Chapter \@ref(paths-to-distributions):

- the **large-time series** builds the solution from sine waves that fit between the
  walls, each dying away at its own rate. That is where the $\sin(k\pi z)$ and
  $\exp(-k^2\pi^2 u / 2)$ terms come from. After a while only the slowest wave is left,
  so few terms are needed at large times;
- the **small-time series** places mirror-image normal bumps on the far side of each
  wall (the "method of images") so that the total is zero at the walls. That is where
  the $(z + 2k)$ terms come from, one per mirror position. At small times the probability
  has not spread far, so only the nearest mirrors matter.

The factor $\exp(-v a z - v^2 t / 2)$ in front adjusts the solution without drift for the
drift.

## Summary

| Level | What it describes |
|---|---|
| Step equation | what happens on one trial, as tiny additions |
| Stochastic integral | where one path is at any time |
| Diffusion equation | where all paths are: a spreading, drifting distribution |
| Absorbing walls | the rate of leaking through each wall is the RT density for each response |
| The two series | exact solutions for that leaking rate, used in fitting |
