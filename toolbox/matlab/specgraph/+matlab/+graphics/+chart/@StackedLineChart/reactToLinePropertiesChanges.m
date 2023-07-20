function reactToLinePropertiesChanges(hObj,eventData)







    switch eventData.ChangedProperty
    case "PlotType"
        reactToPlotTypeChange(hObj,eventData);
    case{"ColorMode","MarkerEdgeColorMode","MarkerFaceColorMode"}
        reactToColorModeChange(hObj,eventData);
    case "LineStyleMode"
        reactToLineStyleModeChange(hObj,eventData);
    end
    hObj.MarkDirty('all');
end

function reactToPlotTypeChange(hObj,eventData)

    oldPlotTypes=eventData.OldPropertyValue;
    newPlotTypes=eventData.NewPropertyValue;
    numPlotsInAxes=hObj.NumPlotsInAxes;
    axesIndex=eventData.AxesIndex;
    for plotIndex=1:numPlotsInAxes(axesIndex)
        oldPlotType=oldPlotTypes;
        if iscell(oldPlotTypes)
            oldPlotType=oldPlotTypes{plotIndex};
        end
        newPlotType=newPlotTypes;
        if iscell(newPlotTypes)
            newPlotType=newPlotTypes{plotIndex};
        end
        plotTypeChanged=~strcmp(newPlotType,oldPlotType);
        if plotTypeChanged
            if strcmp(newPlotType,'scatter')

                setMarker(hObj.LineProperties_I(axesIndex),plotIndex,'o',numPlotsInAxes(axesIndex));
            elseif strcmp(oldPlotType,'scatter')

                setMarker(hObj.LineProperties_I(axesIndex),plotIndex,'none',numPlotsInAxes(axesIndex));
            end
        end
    end
    hObj.createPlotObjects();
    updatePlotObjectDisplayNames(hObj);
end

function setMarker(lineProperties,plotIndex,marker,numPlotsInAxes)

    if numPlotsInAxes==1
        lineProperties.Marker=marker;
    else
        if~iscell(lineProperties.Marker)
            lineProperties.Marker=repmat({lineProperties.Marker},1,numPlotsInAxes);
        end
        lineProperties.Marker{plotIndex}=marker;
    end
end

function updatePlotObjectDisplayNames(hObj)

    for axesIndex=1:length(hObj.AxesProperties_I)
        legendLabels=cellstr(hObj.AxesProperties_I(axesIndex).LegendLabels);
        for plotIndex=1:length(legendLabels)
            hObj.Plots{axesIndex}(plotIndex).DisplayName=legendLabels{plotIndex};
        end
    end
end

function reactToColorModeChange(hObj,eventData)

    lineProperties=hObj.LineProperties_I(eventData.AxesIndex);
    propertyName=eventData.ChangedProperty(1:end-4);
    if strcmp(get(lineProperties,propertyName+"Mode"),'auto')
        seriesIndices=hObj.Presenter.getAxesSeriesIndices(eventData.AxesIndex);
        color=getAutoColor(hObj,lineProperties.NumPlots,seriesIndices,propertyName);
        set(lineProperties,propertyName+"_I",color);
    end
end

function reactToLineStyleModeChange(hObj,eventData)

    lineProperties=hObj.LineProperties_I(eventData.AxesIndex);
    if lineProperties.LineStyleMode=="auto"
        lineStyles=hObj.Presenter.getAxesLineStyles(eventData.AxesIndex);
        lineProperties.LineStyle=hObj.LineStyleOrderInternal(rem(lineStyles-1,numel(hObj.LineStyleOrderInternal))+1);
    end
end