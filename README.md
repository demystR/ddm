# ddm

*The Drift Diffusion Model From Scratch*, part of the [demystR](https://demystr.github.io) series.

A bookdown book that builds the drift diffusion model (DDM) from its equations, in base
R: each part of the model is shown as an equation, as code and as a figure.

## Render

From this folder, run:

```r
install.packages(c("bookdown", "tidyverse"))
bookdown::render_book("index.Rmd", "bookdown::bs4_book")
```

The rendered HTML is written to `docs/`. Readers need only the tidyverse. `rtdists` is
optional (used for one check in "From Paths to Distributions") and is needed only to
regenerate the data with `data-raw/simulate_rdm.R`.

`docs/` is not committed. On every push to `main`, the workflow in
`.github/workflows/deploy.yml` installs R, the tidyverse and bookdown, renders the book
and deploys `docs/` to GitHub Pages.

## Code style

Data handling and the figures whose code is shown use the tidyverse (`read_csv()`,
`dplyr` pipelines with `|>`, `tidyr`, `purrr`, `ggplot2`). The model functions in
`R/ddm_functions.R` are plain vectorised R, because they are numeric formulas that map
term by term onto the equations. The diagram-style figures whose code is hidden (the
step arrows, the path build-up, the coherence panels) use base graphics, via
`R/ddm_plots.R`.

## Structure

The chapter order is set in `_bookdown.yml`. Files are named by part and position, as in
`demyst`.

Before Part 1:

- `index.Rmd`: overview, the equation-code-picture approach, how the book is organised.
- `0a-getting-started.Rmd` (`#getting-started`, unnumbered): RStudio project, folder
  layout (`R/`, `data/`), downloading the files, the optional `rtdists` package.

Part 1: Perceptual Decisions (random-dot motion)

- `1a-the-idea.Rmd` (`#the-idea`): the task (animated display and a figure of what
  coherence means), the data, evidence accumulation in words,
  start, boundaries, RT, the parameter table.
- `1b-step-by-step.Rmd` (`#step-by-step`): four stages from one step to a full trial,
  shorter steps, why the noise is scaled by the square root, the continuous-time
  equation, many trials.
- `1c-predictions.Rmd` (`#predictions`): exact formulas for P(upper) and mean decision
  time, checked against the simulator; the logistic link; the speed-accuracy trade-off.
- `1d-paths-to-distributions.Rmd` (`#paths-to-distributions`): from 1 to 10,000
  simulated trials, the first-passage density formula and code, three checks.
- `1e-fitting.Rmd` (`#fitting`): P01's accuracy blocks; log-likelihood, transforms,
  multi-start `optim`, comparison with the true values, standard errors.
- `1f-checking.Rmd` (`#checking`): sampling from the density (`ddm_sample()`),
  quantile-probability plot, recovery across the 20 participants.
- `1g-selective-influence.Rmd`, `1h-real-data.Rmd`: description only so far.

Part 2: Value-Based Decisions (description only so far)

- `2a-value-as-drift.Rmd`, `2b-deadlines-lapses.Rmd`, `2c-two-attributes.Rmd`,
  `2d-design-recovery.Rmd`.

Part 3: Group-Level Models (description only so far)

- `3a-hierarchical.Rmd`.

Appendix

- `A-calculus.Rmd` (`#calculus`): derivatives and integrals, stochastic integrals, the
  diffusion equation, absorbing boundaries and the two density series.

Chapters not written yet are listed in `ddm.css`, which shows them in red in the
contents; delete a chapter's line there when it is written.

Supporting files:

- `R/ddm_functions.R`: every model function built in the book, under chapter headings.
  `_common.R` loads it before each chapter. Base R only, so it can be used anywhere.
- `R/ddm_plots.R`: plotting helpers for the book's figures (not part of the model).
- `data/rdm.csv`, `data/rdm_truth.csv`: the simulated random-dot motion data (20
  participants, 600 trials each) and their true parameter values.
- `data-raw/simulate_rdm.R`: the script that made them (needs `rtdists`).
- `_common.R`: shared set-up for every chapter (loads the tidyverse and sets the
  ggplot theme); also copies `data/`, `R/` and the
  widgets in `apps/` into `docs/` so the book can link to them.
- `apps/rdm/embed.html`: an animated random-dot motion display (plain HTML and
  JavaScript, no server), embedded in "The Idea" with an `<iframe>`. Buttons set the
  coherence (0-100%) and direction, and "show coherent dots" colours the coherent dots.
  URL options: `?coherence=0.128&direction=left&reveal=1`. Edit this file, not the copy
  in `docs/apps/`.
- `include/`: the shared demystR theme. `demystR.css` sets the colours, fonts and
  callout boxes, `header.html` adds the favicon, and `demystR-footer.html` puts the
  series line and licence in the footer. `ddm.css` holds this book's own rules: the
  list of unwritten chapters, shown in grey italics in the contents.

## Licence

Text, figures and data: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
Code and widgets: MIT. See [LICENSE.md](LICENSE.md). The data are simulated for this book.
