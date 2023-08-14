function numNodesToPlot=plotNodeFigure(figHandle,nodes,paths,labels,...
    options,selectedPaths,loggingNode)





    clf(figHandle);
    if isempty(nodes)
        numNodesToPlot=0;
        return
    end
    [nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lProcessSelectedNodes(nodes,paths,labels,options);
    numNodesToPlot=numel(nodesToPlot);

    switch optionsToPlot.layout
    case getMessageFromCatalog('PlotSeparate')

        ax=zeros(1,numNodesToPlot);


        for idx=1:numNodesToPlot
            ax(idx)=subplot(numNodesToPlot,1,idx,'Parent',figHandle);
            assert(numel(nodesToPlot{idx})==1);

            unit=lGetUnit(nodesToPlot{idx}.series.unit,...
            pathsToPlot{idx},optionsToPlot);
            plotFcn=lGetPlotFcn(nodesToPlot{idx});
            plotFcn(figHandle,nodesToPlot{idx},ax(idx),optionsToPlot,unit,...
            pathsToPlot(idx),labelsToPlot(idx),selectedPaths,loggingNode);
        end
        lLinkAxes(ax,optionsToPlot);

    case getMessageFromCatalog('PlotOverlay')

        [groupIdx,unitsToPlot,functionsToPlot]=...
        lGroupNodesForPlotting(nodesToPlot,pathsToPlot,optionsToPlot);

        numPlots=max(groupIdx);
        ax=zeros(1,numPlots);


        for idx=1:numPlots
            ax(idx)=subplot(numPlots,1,idx,'Parent',figHandle);
            plotIdx=find(groupIdx==idx);
            nodes=nodesToPlot(plotIdx);
            unit=unitsToPlot{plotIdx(1)};
            plotFcn=str2func(functionsToPlot{plotIdx(1)});
            plotFcn(figHandle,nodes,ax(idx),optionsToPlot,unit,pathsToPlot(plotIdx),...
            labelsToPlot(plotIdx),selectedPaths,loggingNode);
        end
        lLinkAxes(ax,optionsToPlot);
    otherwise
        try
            pm_error('physmod:common:logging:sli:dataexplorer:InvalidOption');
        catch ME
            ME.throwAsCaller();
        end
    end
end


function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lProcessSelectedNodes(nodes,paths,labels,options)


    node=nodes{1};
    fcn=simscape.logging.internal.getNodeDisplayOption(node,...
    'GetNodesToPlotFcn',@lFindNodesToPlot);
    [nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=fcn(nodes,...
    paths,labels,options);
end

function[nodesToPlot,pathsToPlot,labelsToPlot,optionsToPlot]=...
    lFindNodesToPlot(nodes,paths,labels,options)


    nodesToPlot={};
    pathsToPlot={};
    labelsToPlot={};
    optionsToPlot=options;

    if isscalar(nodes{1})&&nodes{1}.numChildren>0
        node=nodes{1};
        childIds=simscape.logging.internal.sortChildIds(node);
        for idx=1:numel(childIds)
            childNode=child(nodes{1},childIds{idx});


            if~isscalar(childNode)
                continue
            end


            isPlotted=(childNode(1).numChildren==0);
            if simscape.logging.internal.getNodeDisplayOption(...
                childNode,'IsPlottedByParent',isPlotted)
                assert(numel(childNode)==1);
                nodesToPlot{end+1}=childNode;%#ok<AGROW>
                pathsToPlot{end+1}=[paths{1},childIds(idx)];%#ok<AGROW>
                labelsToPlot{end+1}=childNode.id;%#ok<AGROW>
            end
        end
    elseif~isscalar(nodes{1})
        return
    else

        nodesToPlot=nodes;
        pathsToPlot=paths;
        labelsToPlot=labels;
    end
end

function[groupIdx,unitsToPlot,fcnsToPlot]=lGroupNodesForPlotting(...
    allNodes,allPaths,options)

    allPlotFcns=cellfun(@(n)func2str(lGetPlotFcn(n)),allNodes,'UniformOutput',false);


    allUnits=cellfun(@(n)(n.series.unit),allNodes,'UniformOutput',false);


    for idx=1:numel(allUnits)
        allUnits{idx}=lGetUnit(allUnits{idx},allPaths{idx},options);
    end




    allUnits=strrep(allUnits,getMessageFromCatalog('Invalid'),'1');


    uniqueFcns=unique(allPlotFcns,'stable');
    uniqueUnits=unique(allUnits,'stable');
    groupIdx=zeros(1,numel(allNodes));
    grp=1;
    for i=1:numel(uniqueFcns)
        for j=1:numel(uniqueUnits)
            idx=strcmp(allPlotFcns,uniqueFcns{i})&...
            strcmp(allUnits,uniqueUnits{j});
            if any(idx)
                groupIdx(idx)=grp;
                grp=grp+1;
            end
        end
    end
    unitsToPlot=allUnits;
    fcnsToPlot=allPlotFcns;
end

function fcn=lGetPlotFcn(node)

    fcn=simscape.logging.internal.getNodeDisplayOption(node,'PlotNodeFcn','');


    if isempty(fcn)&&(node(1).numChildren==0)
        fcn=@lPlotNodes;
    end
end

function lPlotNodes(fighandle,nodes,ax,options,units,nodePaths,labels,...
    selectedPaths,loggingNode)

    if~iscell(nodes)
        nodes={nodes};
    end

    legendEntries={};
    timeValuePairs={};



    for idx=1:numel(nodes)
        assert(numel(nodes{idx})==1,'The node must be scalar');
        series=nodes{idx}.series;
        time=series.time;
        values=series.values(units);
        dim=series.dimension;
        numElements=dim(1)*dim(2);

        for j=1:dim(2)
            for i=1:dim(1)
                if numElements>1
                    legendEntries{end+1}=sprintf('%s(%d,%d)',labels{idx},i,j);%#ok<AGROW>
                else
                    legendEntries{end+1}=sprintf('%s',labels{idx});%#ok<AGROW>
                end
            end
        end
        timeValuePairs{end+1}=time;%#ok<AGROW>
        timeValuePairs{end+1}=values;%#ok<AGROW>
    end


    sizeTimeValuePairs=size(timeValuePairs);
    switch options.plotType
    case getMessageFromCatalog('PlotTypeLine')
        lh=plot(ax,timeValuePairs{:},'Marker',options.marker);
    case getMessageFromCatalog('PlotTypeStairs')
        counter=1;
        for idx=1:2:sizeTimeValuePairs(2)
            x(:,counter)=[timeValuePairs{idx}];%#ok<AGROW> 
            y(:,counter)=[timeValuePairs{idx+1}];%#ok<AGROW> 
            counter=counter+1;
        end
        lh=stairs(ax,x,y,'Marker',options.marker);
    case getMessageFromCatalog('PlotTypeStem')
        counter=1;
        for idx=1:2:sizeTimeValuePairs(2)
            x(:,counter)=[timeValuePairs{idx}];%#ok<AGROW> 
            y(:,counter)=[timeValuePairs{idx+1}];%#ok<AGROW> 
            counter=counter+1;
        end
        lh=stem(ax,x,y,'Marker',options.marker);
    end
    for idx=1:numel(lh)
        lh(idx).DisplayName=strrep(legendEntries{idx},'_','\_');
        legendOpt=lGetLegendOption(options.legend,legendEntries);
        legend(lh(idx).Parent,legendOpt);
    end


    title(ax,nodes{1}.id,'Interpreter','none');
    yLabelStr=sprintf('%s',units);
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,yLabelStr,'Interpreter','none');
    grid(ax,'on');


    if isfinite(options.time.start)&&isfinite(options.time.stop)&&...
        (options.time.start<options.time.stop)
        xlim(ax,[options.time.start,options.time.stop]);
    end

    if(options.isExtracted==false)
        lCreateUnitButton(fighandle,ax,nodes,nodePaths,options,...
        selectedPaths,loggingNode);
    end
end

function legendOpt=lGetLegendOption(legend,legendEntries)


    switch legend
    case getMessageFromCatalog('PlotLegendAuto')
        if numel(legendEntries)>1
            legendOpt='show';
        else
            if~isempty(regexp(legendEntries{1},'\.','once'))
                legendOpt='show';
            else
                legendOpt='off';
            end
        end
    case getMessageFromCatalog('PlotLegendAlways')
        if~isempty(legendEntries)
            legendOpt='show';
        end
    case getMessageFromCatalog('PlotLegendNever')
        legendOpt='off';
    end
end

function u=lGetUnit(unit,path,options)


    path=simscape.logging.internal.indexedPathLabel(path);
    u=unit;
    if isKey(options.unitsPerNode,path)
        u=options.unitsPerNode(path);
    else
        if~strcmp(u,getMessageFromCatalog('Invalid'))
            u=lGetOptionUnit(u,options.unit);
        end
    end
end

function u=lGetOptionUnit(unit,option)
    u=unit;
    unitSelection=option;

    if~strcmpi(unitSelection,getMessageFromCatalog('PlotUnitsDefault'))
        [siUnits,usUnits]=lUnitDefinitions;
        switch unitSelection
        case getMessageFromCatalog('PlotUnitsSI')
            units=siUnits;
        case getMessageFromCatalog('PlotUnitsUSCustomary')
            units=usUnits;
        case getMessageFromCatalog('PlotUnitsCustom')
            [msg,units]=lGetCustomUnits;
            if~isempty(msg)
                w=warning('query','backtrace');
                warning('off','backtrace');
                c=onCleanup(@()(warning(w)));
                warning('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
                msg);
            end
        otherwise
        end
        units=lGetValidUnits(units,unitSelection);
        unitIdx=pm_directlyconvertible(unit,units);
        if any(unitIdx)
            u=units{unitIdx};
        end
    end
end

function[siUnits,usUnits]=lUnitDefinitions()


    siUnits={'m/s','N','m','rad/s','rad','N*m','Pa','m^3/s','kg/s',...
    'm^3','m^2/s','K','J','W','J/kg','J/(kg*K)','W/(m*K)',...
    'W/(m^2*K)','kg/m^3','1/K','rad/s^2','m^2','m/s^2'};


    usUnits={'ft/s','lbf','ft','rpm','rev','lbf*ft','psi','gpm','lbm/s',...
    'gal','cSt','Fh','Btu','Btu/hr','Btu/lbm','Btu/(lbm*R)','Btu/(hr*ft*R)',...
    'Btu/(hr*ft^2*R)','lbm/ft^3','1/R','rev/s^2','in^2','ft/s^2'};

end

function[errorMsg,customUnits]=lGetCustomUnits()


    customUnits={};
    errorMsg='';
    fileName='ssc_customlogunits';


    if exist(fileName,'file')
        try
            u=ssc_customlogunits;


            if iscell(u)&&all(pm_isunit(u))
                customUnits=u;
            else
                errorMsg=pm_message('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
                fileName,fileName);
            end
        catch
            errorMsg=pm_message('physmod:common:logging:sli:dataexplorer:InvalidCustomUnits',...
            fileName,fileName);
        end
    end
end

function validUnits=lGetValidUnits(u,name)

    valid=pm_isunit(u);
    invalidUnits=u(~valid);
    validUnits=u(valid);
    if~isempty(invalidUnits)
        str=sprintf('''%s''',invalidUnits{1});
        for idx=2:numel(invalidUnits)
            str=sprintf('%s, ''%s''',str,invalidUnits{idx});
        end
        w=warning('query','backtrace');
        warning('off','backtrace');
        c=onCleanup(@()(warning(w)));
        warning('physmod:common:logging:sli:dataexplorer:InvalidUnitExpression',...
        [getMessageFromCatalog('InvalidUnitExpression',name),' \n%s\n'],str);
    end
end

function lLinkAxes(ax,options)
    if isempty(ax)||isscalar(ax)||~all(ishghandle(ax,'axes'))
        return;
    end
    if options.link
        parent=get(ax(1),'Parent');
        parent.UserData.LinkObject=linkprop(ax,'XLim');
    end
end

function lCreateUnitButton(hFigure,ax,nodes,paths,options,...
    selectedPaths,loggingNode)

    import simscape.logging.internal.*
    for idx=1:numel(paths)
        paths{idx}=indexedPathLabel(paths{idx});
    end

    [yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax);

    colorMatrix=repmat([1,1,1,1,1,1,1
    0,0,0,0,0,0,0
    1,0,0,0,0,0,1
    1,1,0,0,0,1,1
    1,1,1,0,1,1,1
    1,1,1,1,1,1,1
    1,1,1,1,1,1,1],...
    1,1,3);

    yMenu=lCreateUnitMenu(hFigure,get(ax,'YLabel'),...
    nodes,paths,options,selectedPaths,loggingNode);

    yButton=uicontrol('Parent',hFigure,...
    'Style','pushbutton',...
    'Tag',paths{1},...
    'Position',[yButtonX,yButtonY,btnWidth,btnHeight],...
    'CData',colorMatrix,...
    'Callback',{@(src,evt)lShowContextMenuOnButton(src,yMenu)});

    userData.yButton=yButton;
    userData.yMenu=yMenu;
    set(ax,'UserData',userData);


    addlistener(ax,'LocationChanged',@(varargin)lUpdateUnitButton(hFigure,ax));


    hz=zoom(hFigure);
    set(hz,'ActionPostCallback',@lZoomUpdateCallback);


    hr=rotate3d(ax);
    set(hr,'ActionPreCallback',@lHideButton);
    set(hr,'ActionPostCallback',@lRotateUpdateCallback);

    function lZoomUpdateCallback(hFigure,~)


        allAxesInFigure=findall(hFigure,'type','axes');
        for k=1:numel(allAxesInFigure)
            curAx=allAxesInFigure(k);
            curData=get(curAx,'UserData');

            if~isempty(curData)
                lUpdateUnitButton(hFigure,curAx);
            end
        end
    end

    function lHideButton(~,evtData)


        curAx=evtData.Axes;
        tmpUserData=get(curAx,'UserData');
        set(tmpUserData.yButton,'Visible','off');
    end

    function lRotateUpdateCallback(hFigure,evtData)


        curAx=evtData.Axes;
        tmpUserData=get(curAx,'UserData');
        set(tmpUserData.yButton,'Visible','on');
        lUpdateUnitButton(hFigure,curAx);
    end

end

function lRemoveUnitsPerNodeData(options,paths)


    for k=1:numel(paths)
        curPath=char(paths{k});
        if(isKey(options.unitsPerNode,curPath))
            remove(options.unitsPerNode,curPath);
        end
    end
end

function lUpdateUnitButton(hFigure,ax)


    [yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax);

    userData=get(ax,'UserData');
    set(userData.yButton,'Position',[yButtonX,yButtonY,btnWidth,btnHeight]);

end

function[yButtonX,yButtonY,btnWidth,btnHeight]=lGetUnitButtonPosition(hFigure,ax)


    yLabel=get(ax,'YLabel');
    btnHeight=13;
    btnWidth=13;
    btnMargin=1;

    figurePosition=lGetPropertyByUnits(hFigure,'Position','pixels');
    axPosition=lGetPropertyByUnits(ax,'Position','normalized');

    [yButtonX,yButtonY]=lCalculateUnitButtonPosition(figurePosition,...
    axPosition,yLabel,btnWidth,btnHeight,btnMargin);

end

function position=lGetPropertyByUnits(hObject,property,units)


    oldUnits=get(hObject,'Units');
    set(hObject,'Units',units);
    position=get(hObject,property);
    set(hObject,'Units',oldUnits);

end

function[buttonX,buttonY]=lCalculateUnitButtonPosition(figurePosition,...
    axPosition,label,btnWidth,btnHeight,btnMargin)



    labelExtent=lGetPropertyByUnits(label,'Extent','normalized');

    figureWidth=figurePosition(3);
    figureHeight=figurePosition(4);

    axXMargin=axPosition(1);
    axYMargin=axPosition(2);
    axWidth=axPosition(3);
    axHeight=axPosition(4);

    labelXMargin=labelExtent(1);
    labelYMargin=labelExtent(2);
    labelWidth=labelExtent(3);
    labelHeight=labelExtent(4);

    if(get(label,'Rotation')==90)
        buttonX=axXMargin*figureWidth+(labelXMargin+labelWidth)*axWidth*figureWidth-btnWidth;
        buttonY=axYMargin*figureHeight+labelYMargin*axHeight*figureHeight-btnMargin-btnHeight;
    else
        buttonX=axXMargin*figureWidth+labelXMargin*axWidth*figureWidth-btnMargin-btnWidth;
        buttonY=axYMargin*figureHeight+(labelYMargin+labelHeight/2)*axHeight*figureHeight-btnHeight/2;
    end
end

function yMenu=lCreateUnitMenu(figHandle,label,nodes,paths,options,...
    selectedPaths,loggingNode)

    yMenu=uicontextmenu(figHandle);
    unit=get(label,'String');
    optionUnits=pm_suggestunits(unit);
    for i=1:numel(optionUnits)
        elem=optionUnits{i};
        uimenu(yMenu,'Label',elem,'Callback',@(varargin)lRegularCallback(figHandle,elem));
    end
    uimenu(yMenu,'Label',getMessageFromCatalog('PlotUnitsDefault'),'Callback',...
    @(varargin)lDefaultCallback(figHandle));
    uimenu(yMenu,'Label',getMessageFromCatalog('PlotUnitsSpecify'),'Callback',...
    @(varargin)lSpecifyCallback(figHandle,unit));

    function lRegularCallback(figHandle,newUnit)

        lUpdateUnitsPerNodeData(options,paths,newUnit);
        [nodes,paths,labels]=simscape.logging.internal.getExplorerSelectedNodes(...
        selectedPaths,loggingNode);
        simscape.logging.internal.plotNodeFigure(figHandle,nodes,paths,...
        labels,options,selectedPaths,loggingNode);
    end

    function lDefaultCallback(figHandle)


        lRemoveUnitsPerNodeData(options,paths);
        [nodes,paths,labels]=simscape.logging.internal.getExplorerSelectedNodes(...
        selectedPaths,loggingNode);
        simscape.logging.internal.plotNodeFigure(figHandle,nodes,paths,...
        labels,options,selectedPaths,loggingNode);
    end

    function lSpecifyCallback(figHandle,curUnit)



        dlgInput=inputdlg(getMessageFromCatalog('UnitsSpecify'));



        if(~isempty(dlgInput))
            specifiedUnit=char(dlgInput);

            if(pm_isunit(specifiedUnit))
                if(pm_commensurate(unit,specifiedUnit))
                    lUpdateUnitsPerNodeData(options,paths,specifiedUnit);
                    [nodes,paths,labels]=simscape.logging.internal.getExplorerSelectedNodes(...
                    selectedPaths,loggingNode);
                    simscape.logging.internal.plotNodeFigure(figHandle,...
                    nodes,paths,labels,options,...
                    selectedPaths,loggingNode);
                else
                    errordlg(getMessageFromCatalog('NonCommensurateUnit',specifiedUnit,curUnit),...
                    getMessageFromCatalog('CommensurateUnitErrorTitle'));
                end
            else
                errordlg(getMessageFromCatalog('InvalidSpecifiedUnit',specifiedUnit),...
                getMessageFromCatalog('InvalidUnitErrorTitle'));
            end
        end
    end

end

function lUpdateUnitsPerNodeData(options,paths,specifiedUnit)


    for k=1:numel(paths)
        curPath=char(paths{k});
        options.unitsPerNode(curPath)=specifiedUnit;
    end
end

function lShowContextMenuOnButton(hObject,uiContextMenu)




    if~exist('uiContextMenu','var')
        uiContextMenu=get(hObject,'uiContextMenu');
    end

    assert(~isempty(uiContextMenu),getMessageFromCatalog('ContextMenuNotFound'));

    hObjectPos=lGetPropertyByUnits(hObject,'Position','pixels');
    pos=hObjectPos(1:2);
    set(uiContextMenu,'Position',pos);
    set(uiContextMenu,'Visible','on');

end

function lPlotSignalCrossings(~,nodes,ax,options,~,paths,labels,~,~)

    marker=options.marker;
    if strcmpi(marker,getMessageFromCatalog('PlotMarkerNone'))
        marker='x';
    end
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisCrossings'),...
    @lPrepareCrossingDataForCumulativePlot);
end

function lPlotSignalValues(~,nodes,ax,options,~,paths,labels,~,~)

    marker=options.marker;
    lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    getMessageFromCatalog('YAxisValues'),@deal);
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

function lPlotZCSignal(ax,nodes,paths,labels,options,marker,...
    ylab,dataFcn)

    if~iscell(nodes)
        nodes={nodes};
    end

    colors=colororder;
    numColors=size(colors,1);
    for i=1:numel(nodes)
        node=nodes{i};
        assert(numel(node)==1);

        [t,v]=dataFcn(node.series.time,node.series.values);
        colorIdx=1+mod(i-1,numColors);
        switch options.plotType
        case getMessageFromCatalog('PlotTypeLine')
            plot(ax,t,v,'Marker',marker,'Color',colors(colorIdx,:));
        case getMessageFromCatalog('PlotTypeStairs')
            stairs(ax,t,v,'Marker',marker,'Color',colors(colorIdx,:));
        case getMessageFromCatalog('PlotTypeStem')
            stem(ax,t,v,'Marker',marker,'Color',colors(colorIdx,:));
        end
        hold(ax,'on');
    end
    hold(ax,'off');


    legendSelection=options.legend;
    legendEntries=cell(size(paths));
    for idx=1:numel(paths)
        legendEntries{idx}=simscape.logging.internal.indexedPathLabel(paths{idx}(2:end));
    end

    legendEntries=strrep(strrep(strrep(legendEntries,...
    '.SimulationStatistics',''),...
    '.values',''),...
    '.crossings','');

    switch legendSelection
    case{getMessageFromCatalog('PlotLegendAuto'),getMessageFromCatalog('PlotLegendAlways')}
        if~isempty(legendEntries)&&~isempty(get(ax,'Children'))
            legend(ax,legendEntries,'Interpreter','none');
        end
    case getMessageFromCatalog('PlotLegendNever')

    end


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,ylab,'Interpreter','none');
    grid(ax,'on');


    if(~isequal(options.time.start,options.time.stop))
        xlim(ax,[options.time.start,options.time.stop]);
    end
end

function lPlotSimulationStatistics(~,nodes,ax,options,~,~,~,~,~)

    if~iscell(nodes)
        nodes={nodes};
    end
    assert(numel(nodes)==1);
    statisticsNode=nodes{1};

    zcNodeIds=simscape.logging.internal.sortChildIds(statisticsNode);

    time=[];values=[];
    for i=1:numel(zcNodeIds)
        zcNodes=statisticsNode.child(zcNodeIds{i});
        crossingNode=zcNodes(1).crossings;
        if isempty(time)
            time=crossingNode.series.time;
        end
        if isempty(values)
            values=crossingNode.series.values;
        else


            values=[values,crossingNode.series.values];%#ok<AGROW>
        end
    end

    values=sum(values,2);


    [t,v]=lPrepareCrossingDataForCumulativePlot(time,values);


    switch options.plotType
    case getMessageFromCatalog('PlotTypeLine')
        plot(ax,t,v,'Marker','x');
    case getMessageFromCatalog('PlotTypeStairs')
        stairs(ax,t,v,'Marker','x');
    case getMessageFromCatalog('PlotTypeStem')
        stem(ax,t,v,'Marker','x');
    end


    title(ax,'SimulationStatistics (ZeroCrossings)','Interpreter','none');
    xlabel(ax,getMessageFromCatalog('XAxisTime'),'Interpreter','none');
    ylabel(ax,getMessageFromCatalog('YAxisAllCrossings'),'Interpreter','none');
    grid(ax,'on');
    if(~isequal(options.time.start,options.time.stop))
        xlim(ax,[options.time.start,options.time.stop]);
    end
end
