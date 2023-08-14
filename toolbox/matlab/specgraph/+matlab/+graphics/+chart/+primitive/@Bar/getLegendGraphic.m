function graphic=getLegendGraphic(hObj)



    graphic=matlab.graphics.primitive.world.Group;
    face=copyobj(hObj.Face,graphic);
    if~isempty(face.ColorData)
        face.ColorData=face.ColorData(:,1);
        face.ColorBinding='object';
    end
    face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    face.StripData=[];

    edge=copyobj(hObj.Edge,graphic);
    if~isempty(edge.ColorData)
        edge.ColorData=edge.ColorData(:,1);
        edge.ColorBinding='object';
    end
    edge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    edge.VertexIndices=[];
    edge.StripData=uint32([1,5]);
