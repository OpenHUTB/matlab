function index=doGetNearestPoint(hObj,position)








    verts=hObj.VertexData;


    pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=pickUtils.nearestPoint(hObj,position,true,verts(:,1:2));
    index=verts(index,3);
