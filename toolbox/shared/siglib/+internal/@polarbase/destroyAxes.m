function destroyAxes(p)


    ax=destroyStuffThatGetsRestoredWhenPlotIsCalled(p);
    destroyInstanceSpecificStuff(p,ax);
