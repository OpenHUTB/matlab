function out=getSize(hObj,us)




    height=0;
    width=0;

    hintspace=hObj.Axes.HintConsumer;
    bubblesizes=hintspace.BubbleSizeRange;





    labelMediumWidth=0;
    limlabels={'',''};
    if strcmp(hObj.LimitLabelsMode,'auto')
        lims=hintspace.BubbleSizeLimits_I;
        limlabels=cellstr(num2str(lims'))';
        if strcmp(hintspace.BubbleSizeLimitsMode,'manual')&&~isempty(hintspace.BubbleDataLimits)
            extents=hintspace.BubbleDataLimits;
            if~isfinite(lims(1))
                limlabels{1}=num2str(extents(1));
            elseif extents(1)<lims(1)
                limlabels{1}=sprintf('{\\leq}%s',limlabels{1});
            end

            if~isfinite(lims(2))
                limlabels{2}=num2str(extents(2));
            elseif extents(2)>lims(2)
                limlabels{2}=sprintf('{\\geq}%s',limlabels{2});
            end
        end

    elseif hObj.LabelMedium.Visible&&hObj.NumBubbles==3
        [labelMediumWidth,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(us,hObj.LabelMedium);
    else
        limlabels={hObj.LabelBig.String,hObj.LabelSmall.String};
    end




    textObj.String=limlabels{2};
    textObj.Font=hObj.LabelBig.Font;
    textObj.Interpreter=hObj.LabelBig.Interpreter;
    textObj.FontSmoothing=hObj.LabelBig.FontSmoothing;
    [labelBigWidth,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(us,textObj);



    textObj.String=limlabels{1};
    [labelSmallWidth,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(us,textObj);
    maxLabelWidth=max([labelBigWidth,labelMediumWidth,labelSmallWidth]);


    switch hObj.Style
    case 'vertical'
        width=maxLabelWidth+hObj.Padding*2+hObj.AxleWidth+hObj.AxlePadding*2+bubblesizes(2);
        height=hObj.Padding*3+bubblesizes(1)+bubblesizes(2);
        if hObj.NumBubbles==3
            height=height+sqrt(mean(bubblesizes.^2))+hObj.Padding;
        end
    case 'horizontal'
        height=bubblesizes(2)+hObj.Padding*2;
        width=sum(bubblesizes)+hObj.Padding*5+labelBigWidth+labelSmallWidth;
        if hObj.NumBubbles==3
            width=width+sqrt(mean(bubblesizes.^2))+hObj.Padding;
        end

    case 'telescopic'
        height=bubblesizes(2)+hObj.Padding*2;
        width=bubblesizes(2)+maxLabelWidth+hObj.Padding*3;
    end



    textObj.Font.Name=hObj.Title.FontName;
    textObj.Font.Size=hObj.Title.FontSize;
    textObj.Font.Angle=hObj.Title.FontAngle;
    textObj.Font.Weight=hObj.Title.FontWeight;
    textObj.String=hObj.Title.String;
    textObj.Interpreter=hObj.Title.Interpreter;
    textObj.FontSmoothing='on';

    [titleWidth,titleHeight]=hObj.getLabelSizeInPoints(us,textObj);
    titleWidth=titleWidth+hObj.Padding/2;
    titleHeight=titleHeight+hObj.Padding/2;
    height=height+titleHeight;
    width=max([width,titleWidth]);
    out=[width,height];
end

