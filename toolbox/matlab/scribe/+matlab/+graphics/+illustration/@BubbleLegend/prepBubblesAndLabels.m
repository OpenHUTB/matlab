function prepBubblesAndLabels(hObj)



    bubbles=hObj.Bubbles;
    sizes=hObj.BubbleSizes;
    faceColor=hObj.BubbleColor;
    edgeColor=hObj.BubbleEdgeColor;
    alpha=hObj.BubbleAlpha;



    labels=flip(hObj.LimitLabels);
    for i=1:numel(labels)
        if isnumeric(labels{i})
            labels{i}=num2str(labels{i});
        else
            labels{i}=char(labels{i});
        end
    end

    fontsize=hObj.FontSize_I;






    if alpha==1&&strcmp(hObj.Style,'telescopic')
        if~isequal(hObj.BubbleColor,[0,0,0])
            edgeColor=[0,0,0];
        else
            edgeColor=[1,1,1];
        end
    end


    hObj.LabelBig.String=char(labels(1));
    if numel(labels)==3
        hObj.LabelSmall.String=char(labels(3));
        hObj.LabelMedium.String=char(labels(2));
    else
        hObj.LabelMedium.String='';
        hObj.LabelSmall.String=char(labels(2));
    end


    hObj.AxleIsUsed=1;
    for i=1:numel(hObj.LimitLabels)
        if isempty(hObj.LimitLabels{i})
            hObj.AxleIsUsed=0;
        end
    end

    hObj.LabelBig.Font.Size=fontsize;
    hObj.LabelMedium.Font.Size=fontsize;
    hObj.LabelSmall.Font.Size=fontsize;


    hObj.Axle.Visible='off';


    bubbles.LineWidth=hObj.BubbleLineWidth;




















    if hObj.NumBubbles==2
        hObj.LabelMedium.Visible='off';

        faceColorData=zeros(4,4)+255;
        faceColorData(1:4,[2,4])=repmat([faceColor,alpha]'*255,1,2);
        edgeColorData=zeros(4,4)+255;
        edgeColorData(1:3,[2,4])=repmat(edgeColor'*255,1,2);

        set(bubbles,'Size',[sizes(1),sizes(1),sizes(3),sizes(3)],...
        'FaceColorData',uint8(faceColorData),...
        'EdgeColorData',uint8(edgeColorData),...
        'VertexData',single(zeros(3,4)));
    else
        hObj.LabelMedium.Visible=hObj.Visible;

        faceColorData=zeros(4,6)+255;
        faceColorData(1:4,[2,4,6])=repmat([faceColor,alpha]'*255,1,3);
        edgeColorData=zeros(4,6)+255;
        edgeColorData(1:3,[2,4,6])=repmat(edgeColor'*255,1,3);
        set(bubbles,'Size',[sizes(1),sizes(1),sizes(2),sizes(2),sizes(3),sizes(3)],...
        'FaceColorData',uint8(faceColorData),...
        'EdgeColorData',uint8(edgeColorData),...
        'VertexData',single(zeros(3,6)));
    end
end

