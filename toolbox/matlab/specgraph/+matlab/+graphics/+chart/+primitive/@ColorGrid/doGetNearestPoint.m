function index=doGetNearestPoint(hObj,position)








    [ny,nx]=size(hObj.ColorData);
    [x,y]=meshgrid(1:nx,1:ny);
    data=[x(:),y(:)];


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=utils.nearestPoint(hObj,position,true,data);

end
