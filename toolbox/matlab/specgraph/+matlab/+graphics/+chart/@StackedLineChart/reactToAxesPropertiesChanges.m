function reactToAxesPropertiesChanges(hObj,eventData)







    switch eventData.ChangedProperty
    case "LegendLabels"
        reactToLegendLabelsChange(hObj,eventData);
    case "LegendLabelsMode"
        reactToLegendLabelsModeChange(hObj,eventData);
    case "LegendVisibleMode"
        reactToLegendVisibleModeChange(hObj,eventData);
    case "YLabel"
        reactToYLabelChange(hObj,eventData);
    case "XLabel"
        reactToXLabelChange(hObj,eventData);
    case "Title"
        reactToTitleChange(hObj,eventData);
    case "CollapseLegendMode"
        reactToCollapseLegendModeChange(hObj,eventData);
    end
    hObj.MarkDirty('all');
end

function reactToLegendLabelsChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    axesProperties=hObj.AxesProperties_I(axesIndex);
    legendLabels=cellstr(axesProperties.LegendLabels);
    updateLegendLabels(hObj,axesIndex,legendLabels);
end

function updateLegendLabels(hObj,axesIndex,legendLabels)



    for plotIndex=1:length(legendLabels)
        hObj.Plots{axesIndex}(plotIndex).DisplayName=legendLabels{plotIndex};
    end
end

function reactToLegendLabelsModeChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    axesProperties=hObj.AxesProperties_I(axesIndex);
    if axesProperties.LegendLabelsMode=="auto"
        autoLabels=hObj.Presenter.getLegendLabels();
        autoLabels=cellstr(autoLabels{axesIndex});
        axesProperties.LegendLabels_I=autoLabels;
        updateLegendLabels(axesIndex,autoLabels);
    end
end

function reactToLegendVisibleModeChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    axesProperties=hObj.AxesProperties_I(axesIndex);
    if axesProperties.LegendVisibleMode=="auto"
        numPlotsInAxes=hObj.NumPlotsInAxes(axesIndex);
        if numPlotsInAxes>1
            axesProperties.LegendVisible_I='on';
        else
            axesProperties.LegendVisible_I='off';
        end
    end
end

function reactToYLabelChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    hObj.DisplayLabels{axesIndex}=eventData.NewPropertyValue;
end

function reactToXLabelChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    numAxes=numel(hObj.Axes_I);
    if axesIndex==numAxes
        hObj.XLabel=eventData.NewPropertyValue;
    end
end

function reactToTitleChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    if axesIndex==1
        hObj.Title=eventData.NewPropertyValue;
    end
end

function reactToCollapseLegendModeChange(hObj,eventData)

    axesIndex=eventData.AxesIndex;
    axesProperties=hObj.AxesProperties_I(axesIndex);
    if axesProperties.CollapseLegendMode=="auto"
        axesProperties.CollapseLegend_I=hObj.Presenter.getCollapseLegend(eventData.AxesIndex);
    end
end
