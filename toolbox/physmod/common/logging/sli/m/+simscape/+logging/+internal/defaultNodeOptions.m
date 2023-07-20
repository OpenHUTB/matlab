function options=defaultNodeOptions(node)





    assert(numel(node)==1,'The node should be scalar');


    f=@(nv)(~strcmpi(nv{end}.series.unit,getMessageFromCatalog('Invalid')));
    nodesWithData=find(node,f);

    tStart=nan;
    tEnd=nan;
    if~isempty(nodesWithData)
        time=nodesWithData{1}.series.time;
        if(numel(time)>0)
            tStart=time(1);
            tEnd=time(end);
        end
    end


    options.marker=getMessageFromCatalog('PlotMarkerNone');
    options.layout=getMessageFromCatalog('PlotOverlay');
    options.unit=getMessageFromCatalog('PlotUnitsDefault');
    options.plotType=getMessageFromCatalog('PlotTypeLine');
    options.legend=getMessageFromCatalog('PlotLegendAuto');
    options.link=true;
    options.time.start=tStart;
    options.time.stop=tEnd;
    options.unitsPerNode=containers.Map();
    options.isExtracted=false;
end