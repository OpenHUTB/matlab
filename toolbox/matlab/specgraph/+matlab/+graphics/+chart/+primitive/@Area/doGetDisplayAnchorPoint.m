function ret=doGetDisplayAnchorPoint(hObj,index,~)








    x=hObj.AreaLayoutData.XData;
    y=hObj.AreaLayoutData.YData(:,2);
    order=hObj.AreaLayoutData.Order;


    thisIndex=order==index;


    if~any(thisIndex)
        pt=[NaN,NaN,0];
    elseif sum(thisIndex)==1
        pt=[x(thisIndex),y(thisIndex),0];
    else

        x=x(thisIndex);
        y=y(thisIndex);
        [y,ind]=max(y);
        x=x(ind);
        pt=[x,y,0];
    end

    ret=matlab.graphics.shape.internal.util.SimplePoint(pt);
