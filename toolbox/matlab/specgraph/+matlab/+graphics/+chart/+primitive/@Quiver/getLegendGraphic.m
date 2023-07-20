function graphic=getLegendGraphic(hObj)



    graphic=matlab.graphics.primitive.world.Group;

    edge=copyobj(hObj.Tail,graphic);
    edge.VertexData=single([0,1,.7,1,.7;.5,.5,.3,.5,.7;0,0,0,0,0]);
    edge.StripData=uint32([1,3,6]);

    marker=copyobj(hObj.MarkerHandle,graphic);
    marker.VertexData=single([0;.5;0]);
