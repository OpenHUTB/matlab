function hFig=exportPlotToFigure(this,clientId,axesID,copyType,varargin)





    if~isempty(clientId)

        clientObj=Simulink.sdi.WebClient(clientId);
        appName='';
        if strcmpi(clientObj.AppName,'streamout')
            appName='streamout';
        elseif strcmpi(clientObj.AppName,'SDIComparison')
            appName='comparison';
        end
        if~strcmpi(clientObj.Status,'connected')||isempty(clientObj.Axes)
            hFig=matlab.ui.Figure.empty;
            return
        end
    end

    inpParser=inputParser;
    inpParser.CaseSensitive=true;
    inpParser.addOptional('recordBlk',struct());
    inpParser.addParameter('compareRunName','');
    inpParser.addParameter('signalName','');
    inpParser.addParameter('comparisonStatus','');
    inpParser.addParameter('displayList',[]);
    inpParser.addParameter('unplottedSignalID',0);
    inpParser.addParameter('figureProps',{});
    inpParser.parse(varargin{:});

    displayList=inpParser.Results.displayList;
    unplottedSignalID=inpParser.Results.unplottedSignalID;
    compareRunName=inpParser.Results.compareRunName;
    signalName=inpParser.Results.signalName;
    comparisonStatus=inpParser.Results.comparisonStatus;
    figureProps=inpParser.Results.figureProps;
    recordBlkMatrix=inpParser.Results.recordBlk;

    if~isempty(displayList)
        axesIDs=displayList;
    else
        subplotIDs=unique([clientObj.Axes.ParentAxisID]);

        axesIDs=subplotIDs(subplotIDs<=64);
    end
    numPlots=int8(length(axesIDs));
    numRows=int8(numPlots);
    numCols=int8(1);

    layoutMatched=false;

    appInfo=[];
    if strcmp(appName,'streamout')

        if~isempty(recordBlkMatrix)&&isa(recordBlkMatrix,'double')
            appInfo.recordBlk=recordBlkMatrix;
        else
            appInfo.recordBlk=getSimulinkBlockHandle(gcb);
        end
        prefStruct=getRecordBlkTimeLayoutPref(appInfo.recordBlk);
    else
        prefStruct=Simulink.sdi.getViewPreferences();
    end

    numPrefRows=int8(prefStruct.plotPref.numPlotRows);
    numPrefCols=int8(prefStruct.plotPref.numPlotCols);
    layoutType=prefStruct.plotPref.layoutType;


    if strcmp(appName,'comparison')
        numPrefRows=2;
        numPrefCols=1;
        layoutType='2x1_grid';
    end

    if numPrefRows*numPrefCols==numPlots
        numRows=numPrefRows;
        numCols=numPrefCols;
        layoutMatched=true;
    end
    selectedPlotOnly=strcmp(copyType,'copySubplot');
    if selectedPlotOnly

        numRows=1;
        numCols=1;
        selectedPlot=Simulink.sdi.getSelectedPlot(this.sigRepository);
        if(axesID==0)

            axesID=selectedPlot;
        elseif isempty(axesID)
            axesID=selectedPlot;
        end
        axesIDs(1)=axesID;
        numPlots=int8(1);
    end


    if strcmp(appName,'streamout')
        hFig=figure();
    else
        hFig=figure(figureProps{:});
    end

    if strcmpi(comparisonStatus,'Unaligned')
        str=getString(message('SDI:sdi:UnalignedStatus',signalName,compareRunName));
        dim=[0.2,0.4,0.8,0.2];
        annotation(hFig,'textbox',dim,'String',str,'EdgeColor','none');
        return;
    end

    if unplottedSignalID
        locSetComparisonMismatch(unplottedSignalID,hFig);
        return
    end

    if locSplLayout(layoutType)&&~selectedPlotOnly
        createSubPlotsLayout(hFig,numPlots,layoutType);
        switch layoutType
        case{'2x2_col2span','ColumnRight'}
            nRows=2;
            nCols=2;
            plotPos={1,3,[2,4]};
            rcIdx={[1,1],[2,1],[1,2]};
        case{'2x2_col1span','ColumnLeft'}
            nRows=2;
            nCols=2;
            plotPos={[1,3],2,4};
            rcIdx={[1,1],[1,2],[2,2]};
        case{'2x2_row2span','RowBottom'}
            nRows=2;
            nCols=2;
            plotPos={1,[3,4],2};
            rcIdx={[1,1],[2,1],[1,2]};
        case{'2x2_row1span','RowTop'}
            nRows=2;
            nCols=2;
            plotPos={[1,2],3,4};
            rcIdx={[1,1],[2,1],[2,2]};
        case{'overlay2_top','OverlayTop',...
            'overlay2_bottom','OverlayBottom',...
            'overlay2_left','OverlayLeft',...
            'overlay2_right','OverlayRight'}
            nRows=1;
            nCols=1;
            numPlots=1;
            plotPos={1};
            rcIdx={[1,1]};
        otherwise
            return
        end
        for idx=1:numPlots
            hFig.CurrentAxes=subplot(double(nRows),double(nCols),plotPos{idx});
            locAddToFigure(this,idx,rcIdx,numPrefRows,numPrefCols,...
            hFig,appName,appInfo,prefStruct,clientId);
        end


        if locHasOverlays(layoutType)
            rcIdx={[2,1],[1,2]};
            xMin=0.15;
            xMax=0.6;
            yMin=0.15;
            yMax=0.55;
            switch layoutType
            case{'overlay2_top','OverlayTop'}
                xPos=[xMin,xMax];
                yPos=[yMax,yMax];
            case{'overlay2_bottom','OverlayBottom'}
                xPos=[xMin,xMax];
                yPos=[yMin,yMin];
            case{'overlay2_left','OverlayLeft'}
                xPos=[xMin,xMin];
                yPos=[yMax,yMin];
            case{'overlay2_right','OverlayRight'}
                xPos=[xMax,xMax];
                yPos=[yMax,yMin];
            end
            for idx=1:2
                axes('OuterPosition',[xPos(idx),yPos(idx),0.3,0.3],...
                'Parent',hFig,...
                'Unit','norm',...
                'Box','on',...
                'XTickLabelMode','manual',...
                'YTickLabelMode','manual',...
                'UserData','empty');
                locAddToFigure(this,idx,rcIdx,numPrefRows,numPrefCols,...
                hFig,appName,appInfo,prefStruct,clientId);
            end
        end
        return;
    end

    createSubPlots(hFig,numPlots,numRows,numCols);

    if selectedPlotOnly
        flag=checkForVisualizationAndDraw(prefStruct,hFig,true,...
        axesIDs,appInfo,clientId,appName);
        if flag
            return;
        else
            exportTimePlotToFigure(this,clientId,axesIDs(1),hFig,prefStruct);
            return;
        end
    end

    plotIdx=numPlots;
    for rowIdx=1:numRows
        for colIdx=1:numCols

            hFig.CurrentAxes=subplot(double(numRows),...
            double(numCols),...
            double(numPlots-plotIdx+1));
            visualizationID=[];


            if rowIdx<=numPrefRows&&colIdx<=numPrefCols
                visualizationID=locGetVisualizationID(appName,...
                appInfo,rowIdx,colIdx,clientId);
            end
            if isempty(visualizationID)
                axesIdx=numRows*(colIdx-1)+rowIdx;
                exportTimePlotToFigure(this,clientId,axesIDs(axesIdx),hFig,prefStruct);
            elseif layoutMatched
                exportVisualization(hFig,rowIdx,colIdx,appInfo,clientId);
            end
            plotIdx=plotIdx-1;
        end
    end

    if~layoutMatched
        checkForVisualizationAndDraw(prefStruct,hFig,false,axesIDs,...
        appInfo,clientId,appName);
    end

end

function prefStruct=getRecordBlkTimeLayoutPref(recordBlk)
    recordPref=get_param(recordBlk,'PlotPreferences');
    showMarkers=false;
    if strcmp(recordPref.Time.Markers,'Show')
        showMarkers=true;
    end
    prefStruct.Markers=showMarkers;
    layout=utils.recordDialogUtils.getGridFromLayout(recordBlk);

    legendPref.legendPositionRunsView='None';
    if strcmp(recordPref.Time.LegendPosition,'TopLeft')
        legendPref.legendPositionRunsView='top';
    elseif strcmp(recordPref.Time.LegendPosition,'OutsideRight')
        legendPref.legendPositionRunsView='right';
    elseif strcmp(recordPref.Time.LegendPosition,'InsideLeft')
        legendPref.legendPositionRunsView='insideTop';
    elseif strcmp(recordPref.Time.LegendPosition,'InsideRight')
        legendPref.legendPositionRunsView='insideRight';
    end

    prefStruct.legendPref=legendPref;

    prefStruct.ticksPosition=recordPref.Time.TicksPosition;
    prefStruct.tickLabelsDisplayed='All';
    if strcmp(recordPref.Time.TickLabels,'Timeaxis')
        prefStruct.tickLabelsDisplayed='t-Axis';
    elseif strcmp(recordPref.Time.TickLabels,'YAxis')
        prefStruct.tickLabelsDisplayed='y-Axis';
    elseif strcmp(recordPref.Time.TickLabels,'None')
        prefStruct.tickLabelsDisplayed='None';
    end

    prefStruct.GridDisplay=recordPref.Time.GridLines;

    numPrefRows=2;
    numPrefsCols=2;
    if~isempty(layout)
        [numPrefRows,numPrefsCols]=getRowColumnsFromLayout(layout);
    end
    plotPref.layoutType=get_param(recordBlk,'Layout');
    plotPref.numPlotRows=numPrefRows;
    plotPref.numPlotCols=numPrefsCols;
    prefStruct.plotPref=plotPref;
end

function[row,col]=getRowColumnsFromLayout(layout)
    layout(strfind(layout,'['))=[];
    layout(strfind(layout,']'))=[];
    grid=sscanf(layout,'%d');
    if numel(grid)==2
        row=grid(1);
        col=grid(2);
    end
end


function createSubPlots(hFig,numPlots,numRows,numCols)
    if numPlots>1
        defAxesPos=[0.05,0.05,0.95,0.95];
        if numRows>1
            defAxesPos(3)=defAxesPos(3)-0.05;
        end
        if numCols>1
            defAxesPos(4)=defAxesPos(4)-0.05;
        end
        set(hFig,'DefaultAxesPosition',defAxesPos)
    end

    for idx=1:numPlots
        subplot(double(numRows),double(numCols),double(idx),...
        'Parent',hFig,...
        'Unit','norm',...
        'Box','on',...
        'XTickLabelMode','manual',...
        'YTickLabelMode','manual',...
        'UserData','empty');
    end
end


function createSubPlotsLayout(hFig,numPlots,layoutType)
    if locHasOverlays(layoutType)
        axes('OuterPosition',[0,0,1,1],...
        'Parent',hFig,...
        'Unit','norm',...
        'Box','on',...
        'XTickLabelMode','manual',...
        'YTickLabelMode','manual',...
        'UserData','empty');
        return
    end
    switch layoutType
    case{'2x2_col2span','ColumnRight'}
        numRows=2;
        numCols=2;
        plotPos={1,3,[2,4]};
    case{'2x2_col1span','ColumnLeft'}
        numRows=2;
        numCols=2;
        plotPos={[1,3],2,4};
    case{'2x2_row2span','RowBottom'}
        numRows=2;
        numCols=2;
        plotPos={1,[3,4],2};
    case{'2x2_row1span','RowTop'}
        numRows=2;
        numCols=2;
        plotPos={[1,2],3,4};
    otherwise
        return
    end
    if numPlots>1
        defAxesPos=[0.05,0.05,0.95,0.95];
        if numRows>1
            defAxesPos(3)=defAxesPos(3)-0.05;
        end
        if numCols>1
            defAxesPos(4)=defAxesPos(4)-0.05;
        end
        set(hFig,'DefaultAxesPosition',defAxesPos)
    end
    for idx=1:numPlots
        subplot(double(numRows),double(numCols),plotPos{idx},...
        'Parent',hFig,...
        'Unit','norm',...
        'Box','on',...
        'XTickLabelMode','manual',...
        'YTickLabelMode','manual',...
        'UserData','empty');
    end
end


function axes=getAvailableAxis(hFig)
    axes=[];
    numChild=length(hFig.Children);
    for childIdx=numChild:-1:1
        if strcmp(hFig.Children(childIdx).UserData,'empty')
            axes=hFig.Children(childIdx);
            break;
        end
    end
end


function exportVisualization(hFig,rowIdx,colIdx,appInfo,clientId)
    hFig.CurrentAxes.UserData='drawn';
    appInstID=sdi_visuals.getAppInstID(clientId);
    exportFun=sdi_visuals.getExportToFigureFunction(appInstID,rowIdx,colIdx);
    if~isempty(exportFun)
        feval(exportFun,hFig,clientId,rowIdx,colIdx,appInfo);
    end
end


function flag=checkForVisualizationAndDraw(prefStruct,hFig,onePlotOnly,...
    axesIds,appInfo,clientId,appName)
    flag=false;

    numRows=double(prefStruct.plotPref.numPlotRows);
    numCols=double(prefStruct.plotPref.numPlotCols);
    MAX_PLOT_ROWS_COLS=8;
    for rowIdx=1:numRows
        for colIdx=1:numCols
            visualizationID=locGetVisualizationID(appName,appInfo,...
            rowIdx,colIdx,clientId);
            subplotID=MAX_PLOT_ROWS_COLS*(colIdx-1)+rowIdx;

            if~isempty(visualizationID)
                emptyAxis=getAvailableAxis(hFig);
                isDisplayed=find(axesIds==subplotID,1);
                if~isempty(emptyAxis)&&~isempty(isDisplayed)
                    hFig.CurrentAxes=emptyAxis;
                    if onePlotOnly
                        if subplotID==axesIds(1)
                            exportVisualization(hFig,rowIdx,colIdx,appInfo,clientId);
                            flag=true;
                            return;
                        else
                            continue;
                        end
                    else
                        exportVisualization(hFig,rowIdx,colIdx,appInfo,clientId);
                    end
                end
            end
        end
    end
end


function locSetComparisonMismatch(sigID,hFig)

    repo=sdi.Repository(1);
    compID=repo.getSignalParent(sigID);
    if~compID
        compID=sigID;
    end
    dsr=Simulink.sdi.DiffSignalResult(compID);

    switch dsr.Status
    case Simulink.sdi.ComparisonSignalStatus.DataTypeMismatch
        str=getString(message('SDI:sdi:DatatypesMismatchStatus'));
    case Simulink.sdi.ComparisonSignalStatus.StartStopMismatch
        str=getString(message('SDI:sdi:StartStopTimesMismatchStatus'));
    case Simulink.sdi.ComparisonSignalStatus.TimeMismatch
        str=getString(message('SDI:sdi:TimeMismatchStatus'));
    case Simulink.sdi.ComparisonSignalStatus.UnitsMismatch
        str=getString(message('SDI:sdi:UnitsMismatchStatus'));
    case Simulink.sdi.ComparisonSignalStatus.EmptySynced
        str=getString(message('SDI:sdi:EmptySyncedStatus'));
    case Simulink.sdi.ComparisonSignalStatus.Unsupported
        str=getString(message('SDI:sdi:UnsupportedStatus'));
    case Simulink.sdi.ComparisonSignalStatus.Canceled
        str=getString(message('SDI:sdi:CanceledStatus'));
    case Simulink.sdi.ComparisonSignalStatus.Empty
        str=getString(message('SDI:sdi:EmptyBaselineTooltip'));
    otherwise
        str='';
    end

    annotation(hFig,'textbox','String',str,'EdgeColor','none');
end


function ret=locSplLayout(layoutType)
    spanLayouts={'2x2_col2span','ColumnRight',...
    '2x2_col1span','ColumnLeft',...
    '2x2_row2span','RowBottom',...
    '2x2_row1span','RowTop'};
    ret=any(strcmp(spanLayouts,layoutType))||locHasOverlays(layoutType);
end


function ret=locHasOverlays(layoutType)
    ret=contains(layoutType,'overlay','IgnoreCase',true);
end


function locAddToFigure(eng,idx,rcIdx,numPrefRows,numPrefsCols,...
    hFig,appName,appInfo,prefStruct,clientId)
    vizID=[];
    rowIdx=rcIdx{idx}(1);
    colIdx=rcIdx{idx}(2);
    if idx<=numPrefRows*numPrefsCols
        vizID=locGetVisualizationID(appName,appInfo,rowIdx,colIdx,clientId);
    end
    if isempty(vizID)
        axesID=8*(colIdx-1)+rowIdx;
        exportTimePlotToFigure(eng,clientId,axesID,hFig,prefStruct);
    else
        exportVisualization(hFig,rowIdx,colIdx,appInfo,clientId);
    end
end


function vizID=locGetVisualizationID(appName,appInfo,row,col,clientId)
    if strcmp(appName,'comparison')
        vizID=[];
    elseif strcmp(appName,'streamout')
        view=get_param(appInfo.recordBlk,'View');
        subplotID=8*(col-1)+row;
        vizID=view.subplots{int32(subplotID)}.visual.visualName;
        if strcmp(vizID,'timeplotplugin')
            vizID=[];
        end
    else
        appID=sdi_visuals.getAppInstID(clientId);
        vizID=sdi_visuals.getVisualizationID(appID,row,col);
    end
end