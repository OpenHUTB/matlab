function index=doGetNearestPoint(hObj,position)







    hDataSpace=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
    [xData,xDataLeft,xDataRight,yDataBottom,yDataTop,order]=calculateBarRectangleData(hObj,[hObj.BaseValue,hObj.BaseValue]);
    isNonFinite=matlab.graphics.chart.primitive.bar.internal.validateBarRectangleData(hDataSpace,hObj.Horizontal,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);


    xDataLeft=xDataLeft(~isNonFinite);
    xData=xData(~isNonFinite);
    xDataRight=xDataRight(~isNonFinite);
    yDataBottom=yDataBottom(~isNonFinite);
    yDataTop=yDataTop(~isNonFinite);
    faceOrder=order(~isNonFinite);

    [verts,faces]=createBarVertexData(hObj,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);
    numBars=numel(xData);

    faces=reshape(faces,4,numBars).';



    faces(:,[3,4])=faces(:,[4,3]);



    pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    faceIndex=pickUtils.nearestFace(hObj,position,true,faces,verts);

    if isempty(faceIndex)








        midverts=(verts(faces(:,3),:)+verts(faces(:,2),:))./2;

        if strcmp(hObj.Horizontal,'off')
            metric='x';
        else
            metric='y';
        end

        faceIndex=pickUtils.nearestPoint(hObj,position,true,midverts,metric);
    end




    index=faceOrder(faceIndex);
