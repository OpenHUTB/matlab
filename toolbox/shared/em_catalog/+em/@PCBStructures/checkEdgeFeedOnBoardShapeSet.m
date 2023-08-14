function tf=checkEdgeFeedOnBoardShapeSet(obj,boardShape)
    tf=false;

    if~isempty(obj.FeedLocations)

        [~,tf]=inpolygon(obj.FeedLocations(:,1),obj.FeedLocations(:,2),boardShape.ShapeVertices(:,1),boardShape.ShapeVertices(:,2));
        if all(tf)
            isEdgeFed=true;
        end


    end