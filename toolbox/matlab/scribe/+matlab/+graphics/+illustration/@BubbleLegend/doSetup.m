function doSetup(hObj)


    black=uint8([0;0;0;255]);
    addDependencyConsumed(hObj,{'hintconsumer'})

    hObj.Padding=8;
    hObj.AxlePadding=5;
    hObj.AxleWidth=5;
    hObj.NumBubbles=3;
    hObj.Style='vertical';
    hObj.BubbleSizeOrder='descending';
    hObj.BubbleSizes=[50,40,10];
    hObj.NeutralColor=[.4,.4,.4];
    hObj.Type='bubblelegend';

    hObj.LabelBig.Font.Name=hObj.FontName;
    hObj.LabelBig.ColorData=black;

    hObj.LabelMedium.Font.Name=hObj.FontName;
    hObj.LabelMedium.ColorData=black;

    hObj.LabelSmall.Font.Name=hObj.FontName;
    hObj.LabelSmall.ColorData=black;

    hObj.LimitLabels_I=["","",""];


    hObj.Axle.VertexData=single(zeros(3,4));
    hObj.Axle.ColorData=black;
    hObj.Axle.StripData=uint32([1,5]);
    hObj.Axle.ColorBinding='object';


    faceColorData=zeros(4,6);
    faceColorData(4,:)=255;
    faceColorData(1:3,1:3)=255;
    set(hObj.Bubbles,'VertexData',single([zeros(1,6);zeros(1,6);zeros(1,6)]),...
    'Style','circle','FaceColorData',uint8(faceColorData),'FaceColorType','truecoloralpha',...
    'Size',ones(1,6),'FaceColorBinding','discrete','SizeBinding','discrete',...
    'EdgeColorBinding','discrete');

    hObj.BubbleContainer.Anchor=[.5,.5,0];



end