function destroyAxesContent(p)




    ax=destroyStuffThatGetsRestoredWhenPlotIsCalled(p);

    if~p.EnablePlotAfterClose
        destroyInstanceSpecificStuff(p,ax);
    end
