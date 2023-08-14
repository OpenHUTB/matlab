function cData=configData



    persistent pConfigData;

    if isempty(pConfigData)
        cd.icons.dir=fullfile(matlabroot,'toolbox','physmod',...
        'common','logging','sli','m','resources','icons');
        cd.icons.tree.leaf=fullfile(cd.icons.dir,'signal.png');
        cd.icons.tree.interior=fullfile(cd.icons.dir,'nonterminal_node.png');
        cd.icons.tree.statistics=fullfile(cd.icons.dir,'statistics.png');
        cd.icons.tree.zeroCrossing=fullfile(cd.icons.dir,'zero_crossing.png');
        cd.icons.tree.signalCrossings=fullfile(cd.icons.dir,'zc_crossings.png');
        cd.icons.tree.signalValues=fullfile(cd.icons.dir,'zc_values.png');


        cd.data=lGetDataMap(cd.icons);

        pConfigData=cd;
    end

    cData=pConfigData;

end

function dataMap=lGetDataMap(icons)


    dataMap={...
    {'SimulationStatistics','Statistics',...
    struct(...
    'TreeNodeIcon',icons.tree.statistics,...
    'TreeNodeLabelFcn',@lSimulationStatisticsTreeLabel,...
    'PrintStatusFcn',@lSimulationStatisticsPrintStatus,...
    'PrintLocationFcn','',...
    'IsPlottedByParent',true,...
    'GetNodesToPlotFcn',@lSimulationStatisticsNodesToPlot,...
    'PlotNodeFcn',@lPlotSimulationStatistics)
    },...
    {'SimulationStatistics','ZeroCrossing',...
    struct(...
    'TreeNodeIcon',icons.tree.zeroCrossing,...
    'TreeNodeLabelFcn',@lZeroCrossingTreeLabel,...
    'PrintStatusFcn',@lZeroCrossingPrintStatus,...
    'PrintLocationFcn',@lZeroCrossingPrintLocation,...
    'IsPlottedByParent',false,...
    'GetNodesToPlotFcn',@lZeroCrossingNodesToPlot,...
    'PlotNodeFcn','')
    },...
    {'ZeroCrossing','SignalCrossings',...
    struct(...
    'TreeNodeIcon',icons.tree.signalCrossings,...
    'TreeNodeLabelFcn','',...
    'PrintStatusFcn',@lZeroCrossingCrossingsPrintStatus,...
    'PrintLocationFcn','',...
    'IsPlottedByParent',true,...
    'GetNodesToPlotFcn','',...
    'PlotNodeFcn',@lPlotSignalCrossings)
    },...
    {'ZeroCrossing','SignalValues',...
    struct(...
    'TreeNodeIcon',icons.tree.signalValues,...
    'TreeNodeLabelFcn','',...
    'PrintStatusFcn',@lZeroCrossingValuesPrintStatus,...
    'PrintLocationFcn','',...
    'IsPlottedByParent',true,...
    'GetNodesToPlotFcn','',...
    'PlotNodeFcn',@lPlotSignalValues)
    }...
    };
end

function label=lSimulationStatisticsTreeLabel(~)

    label='SimulationStatistics (ZeroCrossings)';
end

function label=lZeroCrossingTreeLabel(node)

    numCrossings=sum(node.crossings.series.values);
    switch numCrossings
    case 0
        label=sprintf('%s - no crossings',node.id);
    case 1
        label=sprintf('%s - 1 crossing',node.id);
    otherwise
        label=sprintf('%s - %d crossings',node.id,numCrossings);
    end

end

function str=lSimulationStatisticsPrintStatus(simulationStatisticsNode)

    node=simulationStatisticsNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');


    hasZCTag=@(n)lHasTagValue(n,'SimulationStatistics','ZeroCrossing');
    isZC=@(x)(hasZCTag(x{end}));

    loggedZeroCrossings=find(node,isZC);

    if~isempty(loggedZeroCrossings)
        numPoints=loggedZeroCrossings{1}.values.series.points;

        countCrossings=@(n)sum(n.crossings.series.values());
        numCrossings=sum(cellfun(countCrossings,loggedZeroCrossings));

    else
        numPoints=NaN;
        numCrossings=NaN;
    end

    str=sprintf(['<html>%s<br/>'...
    ,'%s<br/>'...
    ,'%s<br/>'...
    ,'%s<br/>'...
    ,'%s</html>'],...
    statusTitle,...
    getMessageFromCatalog('StatusId',node.id),...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)),...
    getMessageFromCatalog('NumLoggedZeroCrossings',num2str(numel(loggedZeroCrossings))),...
    getMessageFromCatalog('NumZeroCrossings',num2str(numCrossings)));
end

function str=lZeroCrossingPrintStatus(zcNode)

    str=lSimulationStatisticsPrintStatus(zcNode);
end

function str=lZeroCrossingCrossingsPrintStatus(zcCrossingsNode)

    node=zcCrossingsNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');
    numPoints=node.series.points;
    numCrossings=sum(node.series.values());

    str=sprintf(['<html>%s<br/>'...
    ,'%s<br/>'...
    ,'%s<br/>'...
    ,'%s</html>'],...
    statusTitle,...
    getMessageFromCatalog('StatusId',node.id),...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)),...
    getMessageFromCatalog('NumZeroCrossings',num2str(numCrossings)));
end

function str=lZeroCrossingValuesPrintStatus(zcValuesNode)

    node=zcValuesNode{1};
    statusTitle=getMessageFromCatalog('SelectedNodeStats');
    numPoints=node.series.points;

    str=sprintf(['<html>%s<br/>'...
    ,'%s<br/>'...
    ,'%s</html>'],...
    statusTitle,...
    getMessageFromCatalog('StatusId',node.id),...
    getMessageFromCatalog('NumTimeSteps',num2str(numPoints)));
end

function[str,tip,cbck]=lZeroCrossingPrintLocation(node)

    str='';
    tip='';
    cbck='';

    key='ZeroCrossingLocation';
    if hasTag(node,key)

        tag=getTag(node,key);
        fileLocation=tag{2};

        if~isempty(fileLocation)
            tokens=textscan(fileLocation,'%s%d%d','Delimiter',',');
            fileName=tokens{1}{1};
            fileRow=tokens{2};
            fileCol=tokens{3};

            if exist(which(fileName),'file')
                str=sprintf('<html>%s<a href="%s">%s</a></html>',...
                getMessageFromCatalog('ZeroCrossingLocation',' '),fileName,fileName);
                cbck=@(src)opentoline(which(fileName),fileRow,fileCol);
            else
                str=sprintf('<html>%s</html>',...
                getMessageFromCatalog('ZeroCrossingLocation',fileName));
                cbck='';
            end

        else
            str=sprintf('<html>%s</html>',...
            getMessageFromCatalog('ZeroCrossingLocation',getMessageFromCatalog('ZeroCrossingLocationUnAvailable')));
            cbck='';
        end

        key='ZeroCrossingLocationMessage';
        if hasTag(node,key)
            tag=getTag(node,key);
            fullLocation=strrep(tag{2},'|','<br/>');
            tip=sprintf('<html>%s</html>',fullLocation);
        end
    end
end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lSimulationStatisticsNodesToPlot(nodes,paths,labels,options)

    assert(numel(nodes)==1);

    nodesToPlot=nodes;
    pathsToPlot=paths;
    labelsToPlot=labels;

    optionsToPlot=options;

    optionsToPlot.multi=1;
    optionsToPlot.legend=3;

end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=lZeroCrossingNodesToPlot(nodes,~,~,options)

    assert(numel(nodes)==1);
    node=nodes{1};

    nodesToPlot={node.crossings,node.values};
    pathsToPlot={node.id,node.id};
    labelsToPlot={'crossings','values'};

    optionsToPlot=options;

    optionsToPlot.multi=1;
    optionsToPlot.legend=3;

end

function[tt,vv]=lPrepareCrossingDataForCumulativePlot(t,v)

    idx=find(v>0);
    tstep=[t(1);(1-eps)*t(idx);t(idx)];
    vstep=[v(1);zeros(size(idx));v(idx)];
    [tt,idx]=sort(tstep);
    vv=cumsum(vstep(idx));
    vv=[vv(:);vv(end)]';
    tt=[tt(:);t(end)]';
end

function lPlotSimulationStatistics(nodes,ax,options,~,~,~)

    if~iscell(nodes)
        nodes={nodes};
    end
    assert(numel(nodes)==1);
    statisticsNode=nodes{1};

    zcNodeIds=lSortChildIds(statisticsNode);

    time=[];values=[];
    for i=1:numel(zcNodeIds)
        zcNode=child(statisticsNode,zcNodeIds{i});
        crossingNode=zcNode.crossings;
        if isempty(time)
            time=crossingNode.series.time;
        end
        if isempty(values)
            values=crossingNode.series.values;
        else
            values=values|crossingNode.series.values;
        end
    end


    [t,v]=lPrepareCrossingDataForCumulativePlot(time,values);


    plot(ax,t,v,'Marker','x');


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,getMessageFromCatalog('YAxisAllCrossings'),'Interpreter','none');
    grid(ax,'on');


    if options.time.limit
        set(ax,'XLim',[options.time.start,options.time.stop]);
    end

end

function lPlotZCSignal(ax,nodes,paths,labels,options,marker,ylab,dataFcn)

    if~iscell(nodes)
        nodes={nodes};
    end

    colors=get(gca,'ColorOrder');
    numColors=size(colors,1);
    for i=1:numel(nodes)
        node=nodes{i};
        [t,v]=dataFcn(node.series.time,node.series.values);
        colorIdx=1+mod(i-1,numColors);
        plot(ax,t,v,'Marker',marker,'Color',colors(colorIdx,:));
        hold(ax,'on');
    end
    hold(ax,'off');


    [~,legendSelection]=lGetLegendOptions(options.legend);
    if numel(labels)==1&&isempty(regexp(labels{1},'\.','once'))
        legendEntries=paths;
    else
        legendEntries=labels;
    end
    legendEntries=strrep(strrep(strrep(legendEntries,...
    '.SimulationStatistics',''),...
    '.values',''),...
    '.crossings','');

    switch lower(legendSelection)
    case{getMessageFromCatalog('PlotLegendAuto'),getMessageFromCatalog('PlotLegendAlways')}
        if~isempty(legendEntries)
            legend(legendEntries,'Interpreter','none');
        end
    case getMessageFromCatalog('PlotLegendNever')

    end


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,ylab,'Interpreter','none');
    grid(ax,'on');


    if options.time.limit
        set(ax,'XLim',[options.time.start,options.time.stop]);
    end

end

function lPlotSignalCrossings(nodes,ax,options,~,paths,labels)

    marker=lMarker(options.marker);
    if strcmpi(marker,getMessageFromCatalog('PlotMarkerNone'))
        marker='x';
    end
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisCrossings'),...
    @lPrepareCrossingDataForCumulativePlot);
end

function lPlotSignalValues(nodes,ax,options,~,paths,labels)

    marker=lMarker(options.marker);
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisValues'),@deal);
end
