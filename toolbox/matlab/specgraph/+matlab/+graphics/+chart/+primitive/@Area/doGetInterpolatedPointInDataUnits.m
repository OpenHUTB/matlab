function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)




    x=hObj.AreaLayoutData.XData;
    y=hObj.AreaLayoutData.YData;
    order=hObj.AreaLayoutData.Order;


    x=x(~isnan(order));
    y=y(~isnan(order),2);
    order=order(~isnan(order));



    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    rawindex=utils.nearestPoint(hObj,position,false,x,y);



    index=order(rawindex);

    interp=0;