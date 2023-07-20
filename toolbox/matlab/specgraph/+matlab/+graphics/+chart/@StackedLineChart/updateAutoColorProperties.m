function updateAutoColorProperties(hObj,activeColorOrder)




    if isempty(hObj.Axes_I)
        return
    end
    updateAutoChartColors(hObj,activeColorOrder);
    updateAutoLinePropertiesColors(hObj,activeColorOrder);
end

function updateAutoChartColors(hObj,activeColorOrder)

    colorProperties=["Color","MarkerEdgeColor","MarkerFaceColor"];
    colors=activeColorOrder(1,:);
    for i=1:length(colorProperties)
        mode=get(hObj,colorProperties(i)+"Mode");
        if mode=="auto"
            set(hObj,colorProperties(i)+"_I",colors);
        end
    end
end

function updateAutoLinePropertiesColors(hObj,activeColorOrder)





    for axesIndex=1:numel(hObj.LineProperties_I)
        lineProperties=hObj.LineProperties_I(axesIndex);
        onePlotInAxes=lineProperties.NumPlots==1;
        colorProperties=["Color","MarkerEdgeColor","MarkerFaceColor"];
        colors=getAutoColorsForAxes(hObj,axesIndex,activeColorOrder);
        for i=1:length(colorProperties)
            mode=get(lineProperties,colorProperties(i)+"Mode");
            if mode=="auto"
                colorProperty=colorProperties(i)+"_I";
                topLevelMode=get(hObj,colorProperties(i)+"Mode");
                if onePlotInAxes&&topLevelMode=="manual"

                    topLevelColor=get(hObj,colorProperty);
                    set(lineProperties,colorProperty,topLevelColor);
                else

                    set(lineProperties,colorProperty,colors);
                end
            end
        end
    end
end

function colors=getAutoColorsForAxes(hObj,axesIndex,activeColorOrder)


    colorOrderIndices=hObj.Presenter.getAxesSeriesIndices(axesIndex);
    colorOrderIndices=mod(colorOrderIndices-1,height(activeColorOrder))+1;
    colors=activeColorOrder(colorOrderIndices,:);
end
