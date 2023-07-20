function I=doGetEnclosedPoints(hObj,polygon)







    polygon=brushing.select.translateToContainer(hObj,polygon);


    x=hObj.AreaLayoutData.XData(:,1);
    y=hObj.AreaLayoutData.YData(:,2);
    order=hObj.AreaLayoutData.Order(:,1);

    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    rawI=utils.enclosedPoints(hObj,polygon,x,y);



    I=order(rawI);
    I=I(~isnan(I));
