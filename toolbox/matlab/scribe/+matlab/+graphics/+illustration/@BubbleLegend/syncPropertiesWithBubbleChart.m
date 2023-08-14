function syncPropertiesWithBubbleChart(hObj)






    listOfBubbles=hObj.PlotChildren_I;
    hintspace=hObj.Axes.HintConsumer;




    if numel(listOfBubbles)==1&&numel(listOfBubbles.CData_I)==3
        if isequal(listOfBubbles.MarkerFaceColor_I,'flat')
            hObj.BubbleColor=listOfBubbles.CData_I;
        elseif isequal(listOfBubbles.MarkerFaceColor_I,'auto')
            hObj.BubbleColor=hObj.Axes.Color;
        elseif isequal(listOfBubbles.MarkerFaceColor_I,'none')
            hObj.BubbleColor='none';
        else
            hObj.BubbleColor=listOfBubbles.MarkerFaceColor_I;
        end
        hObj.BubbleAlpha=listOfBubbles.MarkerFaceAlpha_I;
        hObj.BubbleEdgeColor=listOfBubbles.CData_I;
        if strcmp(listOfBubbles.MarkerEdgeColor_I,'flat')
            hObj.BubbleEdgeColor=listOfBubbles.CData_I;
        elseif strcmp(listOfBubbles.MarkerEdgeColor_I,'none')
            hObj.BubbleEdgeColor='none';
        else
            hObj.BubbleEdgeColor=listOfBubbles.MarkerEdgeColor_I;
        end
        hObj.BubbleLineWidth=listOfBubbles.LineWidth;
    else
        hObj.BubbleColor=hObj.NeutralColor;
        hObj.BubbleEdgeColor=hObj.NeutralColor;
        hObj.BubbleLineWidth=hObj.DefaultBubbleLineWidth;
    end



    if strcmp(hObj.LimitLabelsMode,'auto')
        lims=hintspace.BubbleSizeLimits_I;
        limlabels=string(lims);

        if strcmp(hintspace.BubbleSizeLimitsMode,'manual')&&~isempty(hintspace.BubbleDataLimits)
            extents=hintspace.BubbleDataLimits;
            if~isfinite(lims(1))
                limlabels(1)=string(extents(1));
            elseif extents(1)<lims(1)
                limlabels(1)=compose("{\\leq}%s",limlabels(1));
            end

            if~isfinite(lims(2))
                limlabels(2)=string(extents(2));
            elseif extents(2)>lims(2)
                limlabels(2)=compose("{\\geq}%s",limlabels(2));
            end
        end

        hObj.LimitLabels_I=limlabels;

    end


    bubblesizes=hintspace.BubbleSizeRange;
    hObj.BubbleSizes=[bubblesizes(2),sqrt(sum(bubblesizes.^2)/2),bubblesizes(1)];
end

