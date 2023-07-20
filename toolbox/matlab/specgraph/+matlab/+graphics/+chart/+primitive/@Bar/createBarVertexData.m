function[verts,indices]=createBarVertexData(hObj,xData,xDataLeft,xDataRight,yDataBottom,yDataTop)




    numBars=numel(xData);
    numVertices=4*numBars;


    yy=zeros(numVertices,1);
    xx=zeros(numVertices,1);


    yy(1:4:numVertices)=yDataBottom;
    yy(2:4:numVertices)=yDataTop;
    yy(3:4:numVertices)=yDataTop;
    yy(4:4:numVertices)=yDataBottom;


    xx(1:4:numVertices)=xDataLeft;
    xx(2:4:numVertices)=xDataLeft;
    xx(3:4:numVertices)=xDataRight;
    xx(4:4:numVertices)=xDataRight;


    if strcmpi(hObj.Horizontal,'off')
        verts=[xx,yy];
    else
        verts=[yy,xx];
    end


    indices=1:numVertices;
