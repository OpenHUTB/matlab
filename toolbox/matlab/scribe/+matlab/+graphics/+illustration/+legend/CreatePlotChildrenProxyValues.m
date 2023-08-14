function CreatePlotChildrenProxyValues(leg)




    pc=leg.PlotChildren;
    pcs=leg.PlotChildrenSpecified;
    pce=leg.PlotChildrenExcluded;

    plotchild=[pc(:);pcs(:);pce(:)];
    if~isempty(plotchild)
        plotedit({'getProxyValueFromHandle',plotchild});
    end

