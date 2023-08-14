function createAxesProperties(hObj,axesMapping,plotMapping)











    oldAxesProps=shallowCopyNoUpdate(hObj.AxesProperties_I);
    oldAxesProps=expandOldAxesPropertiesLegends(oldAxesProps);
    if hObj.Presenter.ChartDataChanged
        hObj.AxesProperties_I(1:end)=[];
    end


    numAxes=hObj.getNumAxesCapped();
    for axesIndex=1:numAxes
        axesProps=getAxesPropertiesForAxes(hObj,oldAxesProps,axesIndex,axesMapping,plotMapping);
        createOrSetAxesPropertiesForAxes(hObj,axesIndex,axesProps);
        if strcmp(axesProps.YLimitsMode,'manual')
            updateManualYLimits(hObj,axesProps,axesIndex);
        end
        updateYScale(hObj,axesProps,axesIndex);
    end

    updateAxesPropertiesListener(hObj);
end

function oldAxesProps=expandOldAxesPropertiesLegends(oldAxesProps)

    for axesIndex=1:numel(oldAxesProps)
        props=oldAxesProps(axesIndex);
        if~isempty(props.CollapseLegendMapping)&&numel(props.LegendLabels_I)~=numel(props.CollapseLegendMapping)
            props.LegendLabels_I=props.LegendLabels_I(props.CollapseLegendMapping);
        end
        oldAxesProps(axesIndex)=props;
    end
end

function axesProps=getAxesPropertiesForAxes(hObj,oldAxesProps,axesIndex,axesMapping,plotMapping)



    nColumns=hObj.getNumColumnsPerVariableInAxes(axesIndex);
    nPlots=sum(nColumns);
    axesProps=initAxesProperties(nPlots);


    yData=hObj.Presenter.getAxesYData(axesIndex);
    currAxesMapping=getElement(axesMapping,axesIndex);
    currPlotMapping=getElement(plotMapping,axesIndex);
    plotStartIndex=1;
    for varPos=1:length(yData)
        nCol=nColumns(varPos);
        plotIndices=plotStartIndex:(plotStartIndex+nCol-1);
        oldAxesIndex=currAxesMapping(varPos);
        varInOldAxes=0<oldAxesIndex&&oldAxesIndex<=hObj.MaxNumAxes;
        if varInOldAxes
            oldPlotIndex=currPlotMapping(varPos);
            oldPlotIndices=oldPlotIndex:(oldPlotIndex+nCol-1);
            axesProps=copyOldAxesPropertiesForVariable(hObj.Axes_I(axesIndex),axesProps,oldAxesProps(oldAxesIndex),plotIndices,oldPlotIndices);
        else

            labs=cellstr(hObj.Presenter.getLegendLabels(axesIndex));
            axesProps.LegendLabels(plotIndices)=labs(plotIndices);


            axesProps.YScale='linear';
        end


        plotStartIndex=plotStartIndex+nCol;
    end


    if strcmp(axesProps.LegendLabelsMode,'auto')
        axesProps.LegendLabels=cellstr(hObj.Presenter.getLegendLabels(axesIndex));
    end


    if strcmp(axesProps.LegendVisibleMode,'auto')&&nPlots>1
        axesProps.LegendVisible='on';
    end


    if strcmp(axesProps.CollapseLegendMode,'auto')
        axesProps.CollapseLegend=hObj.Presenter.getCollapseLegend(axesIndex);
    end
end

function axesProps=initAxesProperties(nPlots)

    axesProps.LegendLabels=cell(1,nPlots);
    axesProps.LegendLabelsMode='auto';
    axesProps.LegendVisible='off';
    axesProps.LegendVisibleMode='auto';
    axesProps.LegendLocation='northeast';
    axesProps.YLimits=[Inf,-Inf];
    axesProps.YLimitsMode='auto';
    axesProps.YScale='';
    axesProps.CollapseLegend='off';
    axesProps.CollapseLegendMode='auto';
end


function v=getElement(C,i)
    if iscell(C)
        v=C{i};
    else
        v=C(i);
    end
end

function axesProps=copyOldAxesPropertiesForVariable(ax,axesProps,oldAxesProps,plotIndices,oldPlotIndices)



    axesProps.CollapseLegend=oldAxesProps.CollapseLegend_I;
    if strcmp(oldAxesProps.CollapseLegendMode,'manual')
        axesProps.CollapseLegendMode='manual';
    end


    axesProps.LegendLabels(plotIndices)=oldAxesProps.LegendLabels_I(oldPlotIndices);
    axesProps.LegendLocation=oldAxesProps.LegendLocation_I;


    if strcmp(oldAxesProps.LegendLabelsMode,'manual')
        axesProps.LegendLabelsMode='manual';
    end
    if strcmp(oldAxesProps.LegendVisibleMode,'manual')
        axesProps.LegendVisibleMode='manual';
        if strcmp(oldAxesProps.LegendVisible_I,'on')
            axesProps.LegendVisible='on';
        end
    end


    if strcmp(oldAxesProps.YLimitsMode,'manual')
        axesProps.YLimitsMode='manual';
        if isa(ax.YAxis,'matlab.graphics.axis.decorator.NumericRuler')
            oldylimits=oldAxesProps.YLimits;
        else
            oldylimits=makeNumeric(ax.YAxis,oldAxesProps.YLimits);
        end
        axesProps.YLimits=[...
        min(axesProps.YLimits(1),oldylimits(1)),...
        max(axesProps.YLimits(2),oldylimits(2))...
        ];
    end



    if~strcmp(axesProps.YScale,'linear')
        axesProps.YScale=oldAxesProps.YScale;
    end
end

function createOrSetAxesPropertiesForAxes(hObj,axesIndex,axesProps)
    props={...
    'Axes',hObj.Axes_I(axesIndex),...
    'AxesIndex',axesIndex,...
    'Presenter',hObj.Presenter,...
    'LegendLabels_I',axesProps.LegendLabels,...
    'LegendLabelsMode',axesProps.LegendLabelsMode,...
    'LegendVisible_I',axesProps.LegendVisible,...
    'LegendVisibleMode',axesProps.LegendVisibleMode,...
    'LegendLocation_I',axesProps.LegendLocation,...
    'YLimitsMode',axesProps.YLimitsMode,...
    'YScale_I',axesProps.YScale,...
    'CollapseLegend_I',axesProps.CollapseLegend,...
    'CollapseLegendMode',axesProps.CollapseLegendMode...
    };
    if hObj.Presenter.ChartDataChanged
        hObj.AxesProperties_I(axesIndex)=matlab.graphics.chart.stackedplot.StackedAxesProperties(props{:});
    else
        set(hObj.AxesProperties_I(axesIndex),props{:});
    end
end

function updateManualYLimits(hObj,axesProps,axesIndex)


    if isa(hObj.Axes_I(axesIndex).YAxis,'matlab.graphics.axis.decorator.NumericRuler')
        yLimits=axesProps.YLimits;
    else
        yLimits=makeNonNumeric(hObj.Axes_I(axesIndex).YAxis,axesProps.YLimits);
    end
    hObj.AxesProperties_I(axesIndex).YLimits_I=yLimits;
    hObj.Axes_I(axesIndex).YAxis.Limits=yLimits;
end

function updateYScale(hObj,axesProps,axesIndex)


    if isempty(axesProps.YScale)
        axesProps.YScale='linear';
    end
    hObj.Axes_I(axesIndex).YScale=axesProps.YScale;
end

function updateAxesPropertiesListener(hObj)

    if~isempty(hObj.AxesPropertiesListener)
        delete(hObj.AxesPropertiesListener);
    end
    hObj.AxesPropertiesListener=event.listener(hObj.AxesProperties_I,...
    'PropertiesChanged',@(~,eventData)reactToAxesPropertiesChanges(hObj,eventData));
end
