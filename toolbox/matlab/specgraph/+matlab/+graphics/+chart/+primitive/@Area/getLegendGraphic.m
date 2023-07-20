function graphic=getLegendGraphic(hObj)




    graphic=matlab.graphics.primitive.world.Group;


    if~isempty(hObj.Face)&&isvalid(hObj.Face)
        face=matlab.graphics.primitive.world.Quadrilateral;
        face.Parent=graphic;
        face.ColorBinding=hObj.Face.ColorBinding;
        face.ColorData=hObj.Face.ColorData;
        face.ColorType=hObj.Face.ColorType;
        face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
        face.VertexIndices=[];
        face.StripData=[];
    end


    if~isempty(hObj.Edge)&&isvalid(hObj.Edge)
        edge=matlab.graphics.primitive.world.LineLoop;
        edge.Parent=graphic;
        edge.LineJoin='miter';
        edge.LineStyle=hObj.Edge.LineStyle;
        edge.LineWidth=hObj.Edge.LineWidth;
        edge.ColorBinding=hObj.Edge.ColorBinding;
        edge.ColorData=hObj.Edge.ColorData;
        edge.ColorType=hObj.Edge.ColorType;
        edge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
        edge.StripData=uint32([1,5]);
        edge.AlignVertexCenters='on';
    end
