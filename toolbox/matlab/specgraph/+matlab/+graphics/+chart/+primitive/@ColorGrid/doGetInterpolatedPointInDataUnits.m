function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)










    [ny,nx]=size(hObj.ColorData);
    [x,y]=meshgrid(1:nx,1:ny);
    data=[x(:),y(:)];


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=utils.nearestPoint(hObj,position,false,data);
    interp=0;

end
