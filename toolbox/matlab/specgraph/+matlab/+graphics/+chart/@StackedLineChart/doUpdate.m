function doUpdate(hObj,updateState)




    try
        if~isempty(hObj.Axes_I)&&isempty(hObj.Plots)


            return
        end
        if hObj.Presenter.ChartDataChanged
            hObj.Presenter.clearWarnings();
        end
        validateChartState(hObj);
        if~hObj.IsPrinting
            hObj.createGraphicsObjects(hObj.OldState);
        end
        applyColorOrder(hObj);
        updatePlotObjects(hObj);
        updateVariablesNotShownMessage(hObj);
        updateZoomAndPan(hObj);
        hObj.doLayout(updateState);
        updateDataCursor(hObj);
        hObj.OldState=hObj.Presenter.copyState();
        hObj.JustCreated=false;
        hObj.Presenter.ChartDataChanged=false;
        hObj.Presenter.issueWarnings();
    catch ME
        hObj.logWarning(ME.identifier,'%s',ME.message);
        hObj.Presenter.issueWarnings();
    end
end

function applyColorOrder(hObj)







    activeColorOrder=getActiveColorOrder(hObj);
    hObj.updateAutoColorProperties(activeColorOrder);
end

function activeColorOrder=getActiveColorOrder(hObj)



    if strcmp(hObj.ColorOrderInternalMode,'auto')&&~isempty(hObj.Parent)
        activeColorOrder=get(hObj.Parent,'DefaultAxesColorOrder');
    else
        activeColorOrder=hObj.ColorOrderInternal;
    end
end

function validateChartState(hObj)

    try
        validateChartLegendLabels(hObj);
        hObj.Presenter.validate();
    catch ME
        hObj.hideAxes();
        set(hObj.ChartLegendHandle,Visible="off");
        rethrow(ME);
    end
end

function validateChartLegendLabels(hObj)

    if hObj.LegendLabelsMode=="auto"
        autoLabels=hObj.Presenter.getChartLegendLabels();
        if isempty(hObj.LegendLabels_I)
            hObj.LegendLabels_I=autoLabels;
        else
            emptyLabels=cellfun('isempty',hObj.LegendLabels_I);
            hObj.LegendLabels_I(emptyLabels)=autoLabels(emptyLabels);
        end
        return
    end
    if iscell(hObj.SourceTable_I)
        if numel(hObj.LegendLabels_I)>numel(hObj.SourceTable_I)
            error(message('MATLAB:stackedplot:SourceTableLegendLabelsInvalidSize'));
        end
    elseif numel(hObj.LegendLabels_I)>1
        error(message('MATLAB:stackedplot:SourceTableLegendLabelsInvalidSize'));
    end
end

function updatePlotObjects(hObj)

    if isempty(hObj.Plots)
        return
    end
    numAxesShown=hObj.getNumAxesCapped();
    for axesIndex=1:numAxesShown
        xCell=hObj.Presenter.getAxesXData(axesIndex);
        yCell=hObj.Presenter.getAxesYData(axesIndex);
        plotIndex=1;
        for varIndex=1:length(yCell)

            if isscalar(xCell)
                x=makeRealIfNumeric(xCell{1});
            else
                x=makeRealIfNumeric(xCell{varIndex});
            end
            y=makeRealIfNumeric(yCell{varIndex});
            y=y(:,:);
            for j=1:width(y)
                updatePlotObject(hObj,axesIndex,plotIndex,x,y(:,j));
                plotIndex=plotIndex+1;
            end
        end
    end
end

function v=makeRealIfNumeric(v)
    if isnumeric(v)
        v=real(v);
    end
end

function updatePlotObject(hObj,axesIndex,plotIndex,x,y)



    plot=hObj.Plots{axesIndex}(plotIndex);
    plot.XData=x;
    plot.YData=y;


    isLine=isa(plot,'matlab.graphics.chart.primitive.Line');
    isStair=isa(plot,'matlab.graphics.chart.primitive.Stair');
    if isLine||isStair
        plot.Color=getPlotColor(hObj,axesIndex,plotIndex);
        plot.LineStyle=getPlotLineStyle(hObj,axesIndex,plotIndex);
        plot.LineWidth=getPlotLineWidth(hObj,axesIndex,plotIndex);
    end


    plot.Marker=getPlotMarker(hObj,axesIndex,plotIndex);
    markerSize=getPlotMarkerSize(hObj,axesIndex,plotIndex);
    isScatter=isa(plot,'matlab.graphics.chart.primitive.Scatter');
    if isScatter
        plot.SizeData=markerSize.^2;
    else
        plot.MarkerSize=markerSize;
    end
    plot.MarkerFaceColor=getPlotMarkerFaceColor(hObj,axesIndex,plotIndex);
    plot.MarkerEdgeColor=getPlotMarkerEdgeColor(hObj,axesIndex,plotIndex);
end

function color=getPlotColor(hObj,axesIndex,plotIndex)

    color=hObj.LineProperties_I(axesIndex).Color;
    if~isrow(color)
        color=color(plotIndex,:);
    end
end

function lineStyle=getPlotLineStyle(hObj,axesIndex,plotIndex)

    lineStyle=hObj.LineProperties_I(axesIndex).LineStyle;
    if iscell(lineStyle)
        lineStyle=lineStyle{plotIndex};
    end
end

function lineWidth=getPlotLineWidth(hObj,axesIndex,plotIndex)

    lineWidth=hObj.LineProperties_I(axesIndex).LineWidth;
    if~isscalar(lineWidth)
        lineWidth=lineWidth(plotIndex);
    end
end

function markerStyle=getPlotMarker(hObj,axesIndex,plotIndex)

    markerStyle=hObj.LineProperties_I(axesIndex).Marker;
    if iscell(markerStyle)
        markerStyle=markerStyle{plotIndex};
    end
end

function markerSize=getPlotMarkerSize(hObj,axesIndex,plotIndex)

    markerSize=hObj.LineProperties_I(axesIndex).MarkerSize;
    if~isscalar(markerSize)
        markerSize=markerSize(plotIndex);
    end
end

function faceColor=getPlotMarkerFaceColor(hObj,axesIndex,plotIndex)

    faceColor=hObj.LineProperties_I(axesIndex).MarkerFaceColor;
    if~isrow(faceColor)
        faceColor=faceColor(plotIndex,:);
    end
end

function edgeColor=getPlotMarkerEdgeColor(hObj,axesIndex,plotIndex)

    edgeColor=hObj.LineProperties_I(axesIndex).MarkerEdgeColor;
    if~isrow(edgeColor)
        edgeColor=edgeColor(plotIndex,:);
    end
end

function updateVariablesNotShownMessage(hObj)


    hContainer=ancestor(hObj,'matlab.ui.internal.mixin.CanvasHostMixin','node');
    chartMovedToAnotherFigure=...
    ~isempty(hObj.MessageHandle)&&...
    ~isequal(hContainer,ancestor(hObj.MessageHandle,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
    if chartMovedToAnotherFigure


        delete(hObj.MessageHandle);
        hObj.MessageHandle=matlab.graphics.shape.TextBox.empty;
    end


    if isempty(hObj.MessageHandle)&&~isempty(hContainer)
        createVariablesNotShownMessage(hObj,hContainer);
    end
end

function createVariablesNotShownMessage(hObj,hContainer)


    try
        hObj.MessageHandle=annotation(hContainer,'Textbox',...
        'LineStyle','none',...
        'Color',[0,0.6,1],...
        'VerticalAlignment','bottom',...
        'HorizontalAlignment','left',...
        'Units',hObj.Units,...
        'Interpreter','none',...
        'FontName',hObj.FontName,...
        'FontSize',hObj.FontSize*1.1,...
        'HandleVisibility','off',...
        'HitTest','off',...
        'PickableParts','none',...
        'Serializable',false,...
        'Internal',true...
        );
    catch ME

        if~strcmp(ME.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')
            rethrow(ME);
        end
    end
end

function updateZoomAndPan(hObj)

    fig=ancestor(hObj,'figure');
    chartMovedToAnotherFigure=...
    ~isempty(hObj.ZoomInteraction)&&...
    ~isequal(hObj.ZoomInteraction(1).zoom_handle.Figure,fig);
    if chartMovedToAnotherFigure


        hObj.ZoomInteraction=hObj.ZoomInteraction([]);
        hObj.PanInteraction=hObj.PanInteraction([]);
    end


    if isempty(hObj.ZoomInteraction)||isempty(hObj.PanInteraction)
        createZoomAndPan(hObj,fig);
    end
end

function createZoomAndPan(hObj,fig)

    import matlab.graphics.chart.internal.stackedplot.StackedInteractionStrategy
    hAx=hObj.Axes_I;
    for axesIndex=1:length(hAx)
        ax=hAx(axesIndex);
        strategy=StackedInteractionStrategy(ax,hObj);
        hObj.ZoomInteraction(axesIndex)=createZoom(ax,fig,strategy);
        hObj.PanInteraction(axesIndex)=createPan(ax,fig,strategy);
    end
end

function zoom=createZoom(ax,fig,strategy)

    import matlab.graphics.interaction.uiaxes.ScrollZoom
    zoom=ScrollZoom(ax,fig,'WindowScrollWheel','WindowMouseMotion');
    zoom.strategy=strategy;
    zoom.enable();
end

function pan=createPan(ax,fig,strategy)

    import matlab.graphics.interaction.uiaxes.Pan
    pan=Pan(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
    pan.strategy=strategy;
    pan.enable();
end

function updateDataCursor(hObj)

    import matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor
    if isempty(hObj.DataCursor)
        hObj.DataCursor=StackedLineDataCursor(hObj);
    end
end
