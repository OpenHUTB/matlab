function width=getWidthOfLegendInPoints(hObj,updateState)


    maxBubble=max(hObj.Bubbles.Size);
    [maxLabel,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(updateState,hObj.LabelBig);
    minBubble=min(hObj.Bubbles.Size);
    [minLabel,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(updateState,hObj.LabelSmall);





    midBubble=0;
    midLabel=0;
    if hObj.NumBubbles==3
        midBubble=hObj.Bubbles.Size(3);
        if~strcmp(hObj.Style,'horizontal')
            [midLabel,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(updateState,hObj.LabelMedium);
        end
    end

    longestLabel=max([maxLabel,minLabel,midLabel]);

    switch hObj.Style
    case 'vertical'
        axlePadding=(hObj.AxlePadding*2+hObj.AxleWidth)*hObj.AxleIsUsed;
        width=longestLabel+maxBubble+hObj.Padding*2+axlePadding;
    case 'horizontal'
        width=maxBubble+maxLabel+minBubble+minLabel+midBubble+...
        hObj.Padding*(hObj.NumBubbles+3);
    case 'telescopic'
        width=maxBubble+longestLabel+hObj.Padding*3;
    end

end
