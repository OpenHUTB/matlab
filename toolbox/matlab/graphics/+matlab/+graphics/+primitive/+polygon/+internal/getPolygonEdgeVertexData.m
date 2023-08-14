function[vd,sd,hvd,hsd]=getPolygonEdgeVertexData(polygon)







    hvd=[];
    hsd=uint32([]);

    if polygon.Shape.NumHoles>0
        polygonNoHoles=rmholes(polygon.Shape);

        [vd,sd]=matlab.graphics.primitive.polygon.internal.getPolygonVertexData(polygonNoHoles.Vertices);
        polygonHoles=holes(polygon.Shape);


        for i=1:polygon.Shape.NumHoles
            if i==polygon.Shape.NumHoles
                hvd=[hvd;polygonHoles(i).Vertices];
            else
                hvd=[hvd;polygonHoles(i).Vertices;NaN,NaN];
            end
        end
        [hvd,hsd]=matlab.graphics.primitive.polygon.internal.getPolygonVertexData(hvd);
    else
        [vd,sd]=matlab.graphics.primitive.polygon.internal.getPolygonVertexData(polygon.Shape.Vertices);
    end

end

