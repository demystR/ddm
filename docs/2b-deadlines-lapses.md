# Deadlines And Lapses {#deadlines-lapses}

*This chapter has not been written yet.*

Two features of real data that the basic model does not handle. **Deadlines**: if
responses slower than, say, 3 s are not recorded, a timeout still says that neither
boundary was reached by 3 s, and its likelihood is the probability of that event.
Dropping timeouts would remove the slowest, most cautious decisions. **Lapses**: a few
responses are guesses or slips, and one very fast one can dominate a fit (Chapter
\@ref(fitting)). A small mixture of random responses fixes this.
