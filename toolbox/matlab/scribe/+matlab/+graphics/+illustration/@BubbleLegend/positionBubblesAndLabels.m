function positionBubblesAndLabels(hObj,width,height,titleHeight,updateState)





    bubbles=hObj.Bubbles;
    maxSize=max(bubbles.Size);
    hObj.LabelBig.VerticalAlignment='middle';
    hObj.LabelSmall.VerticalAlignment='middle';
    hObj.LabelMedium.VerticalAlignment='middle';


    onlyTwoBubbles=2;

    if hObj.NumBubbles==3
        midIdx=3;
        midSize=bubbles.Size(midIdx);
        onlyTwoBubbles=0;
    end


    switch hObj.Style

    case 'vertical'


        xBubble=-width/2+hObj.Padding+maxSize/2;
        bubbles.VertexData(1,:)=xBubble;


        if strcmp(hObj.BubbleSizeOrder,'descending')
            topIdx=1;
            botIdx=5-onlyTwoBubbles;
            topLabel=hObj.LabelBig;
            botLabel=hObj.LabelSmall;
        else
            topIdx=5-onlyTwoBubbles;
            botIdx=1;
            topLabel=hObj.LabelSmall;
            botLabel=hObj.LabelBig;
        end

        topSize=bubbles.Size(topIdx);
        botSize=bubbles.Size(botIdx);

        topY=height/2-hObj.Padding-topSize/2;
        botY=-height/2+hObj.Padding+botSize/2;

        bubbles.VertexData(2,[topIdx,topIdx+1])=topY;
        bubbles.VertexData(2,[botIdx,botIdx+1])=botY;


        if hObj.AxleIsUsed
            axleXLeft=bubbles.VertexData(1)+maxSize/2+hObj.AxlePadding;
            axleXRight=axleXLeft+hObj.AxleWidth;
            hObj.Axle.VertexData(1,:)=single([axleXRight,axleXLeft,axleXLeft,axleXRight]);
            hObj.Axle.VertexData(2,:)=single([botY,botY,topY,topY]);
            hObj.Axle.Visible='on';
        end


        xLabel=xBubble+(hObj.AxlePadding*2+hObj.AxleWidth)*hObj.AxleIsUsed+maxSize/2;
        topLabel.VertexData=single([xLabel;topY;0]);
        botLabel.VertexData=single([xLabel;botY;0]);


        if hObj.NumBubbles==3
            midSize=bubbles.Size(midIdx);
            midY=height/2-hObj.Padding*2-topSize-midSize/2;
            bubbles.VertexData(2,[midIdx,midIdx+1])=midY;
            hObj.LabelMedium.VertexData=single([xLabel;midY;0]);

        end

    case 'horizontal'


        if strcmp(hObj.BubbleSizeOrder,'descending')
            leftIdx=1;
            rightIdx=5-onlyTwoBubbles;
            leftLabel=hObj.LabelBig;
            rightLabel=hObj.LabelSmall;
        else
            leftIdx=5-onlyTwoBubbles;
            rightIdx=1;
            leftLabel=hObj.LabelSmall;
            rightLabel=hObj.LabelBig;
        end

        leftSize=bubbles.Size(leftIdx);
        rightSize=bubbles.Size(rightIdx);


        [rightLabelWidth,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(updateState,rightLabel);
        [leftLabelWidth,~]=matlab.graphics.illustration.BubbleLegend.getLabelSizeInPoints(updateState,leftLabel);
        leftLabel.VertexData=single([-width/2+hObj.Padding;0;0]);
        rightLabel.VertexData=single([width/2-hObj.Padding-rightLabelWidth;0;0]);
        hObj.LabelMedium.Visible='off';


        bubbles.VertexData(1,[leftIdx,leftIdx+1])=...
        -width/2+hObj.Padding*2+leftSize/2+leftLabelWidth;
        bubbles.VertexData(1,[rightIdx,rightIdx+1])=...
        width/2-hObj.Padding*2-rightSize/2-rightLabelWidth;

        if hObj.NumBubbles==3
            bubbles.VertexData(1,[midIdx,midIdx+1])=...
            width/2-hObj.Padding*3-rightSize-rightLabelWidth-midSize/2;
        end

    case 'telescopic'


        xBubble=-width/2+hObj.Padding+maxSize/2;
        bubbles.VertexData(1,:)=xBubble;


        xLabel=xBubble+maxSize/2+hObj.Padding;
        hObj.LabelBig.VertexData=single([xLabel;maxSize/2;0]);
        hObj.LabelMedium.VertexData=single([xLabel;0;0]);
        hObj.LabelSmall.VertexData=single([xLabel;-maxSize/2;0]);

        hObj.LabelBig.VerticalAlignment='top';
        hObj.LabelSmall.VerticalAlignment='bottom';


        if hObj.NumBubbles==3
            bubbles.VertexData(2,[1,2])=0;
            bubbles.VertexData(2,[3,4])=0-maxSize/2+bubbles.Size(3)/2;
            bubbles.VertexData(2,[5,6])=0-maxSize/2+bubbles.Size(5)/2;
        else
            bubbles.VertexData(2,[1,2])=0;
            bubbles.VertexData(2,[3,4])=0-maxSize/2+bubbles.Size(3)/2;
        end

    end


    hObj.BubbleContainer.Anchor(2)=(height/2)/(titleHeight+height);

end