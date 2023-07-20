function tf=isEdgeFeedViaAlongXorY(obj,boardshape)
    if nargin<2
        TR=triangulation(obj.BoardShape.InternalPolyShape);
    else
        TR=triangulation(boardshape.InternalPolyShape);
    end
    e=freeBoundary(TR);
    tfeed=em.MeshGeometry.isPointAlongXorY(TR,e,obj.FeedLocations);
    tf=all(tfeed);
    if~isempty(obj.ViaLocations)
        tvia=em.MeshGeometry.isPointAlongXorY(TR,e,obj.ViaLocations);
        tvia=all(tvia);
        tf=tf&&tvia;
    end

end



