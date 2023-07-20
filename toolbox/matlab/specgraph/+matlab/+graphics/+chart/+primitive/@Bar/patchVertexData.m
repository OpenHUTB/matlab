function[faces,vertices]=patchVertexData(hObj)





    if strcmpi(hObj.Horizontal,'off')
        basevalues=[0,hObj.BaseValue,0];
    else
        basevalues=[hObj.BaseValue,0,0];
    end


    [xData,xDataLeft,xDataRight,yDataBottom,yDataTop]=calculateBarRectangleData(hObj,basevalues);
    isNonFinite=matlab.graphics.chart.primitive.bar.internal.validateBarRectangleData([],hObj.Horizontal,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);


    xDataLeft=xDataLeft(~isNonFinite);
    xData=xData(~isNonFinite);
    xDataRight=xDataRight(~isNonFinite);
    yDataBottom=yDataBottom(~isNonFinite);
    yDataTop=yDataTop(~isNonFinite);

    [vertices,faceIndices]=createBarVertexData(hObj,xData,xDataLeft,xDataRight,yDataBottom,yDataTop);
    numBars=numel(xData);



    faces=reshape(faceIndices,4,numBars)';

end
