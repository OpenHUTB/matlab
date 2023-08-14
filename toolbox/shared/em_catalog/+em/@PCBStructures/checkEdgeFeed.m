function[isEdgeFed,tf]=checkEdgeFeed(obj)
    isEdgeFed=false;
    tf=false;
    if isequal(size(obj.modifiedFeedLocations,2),4)
        if isempty(obj.BoardShape.ShapeVertices)
            isEdgeFed=false;
            tf=bool(zeros(1,numel(obj.modifieViaLocation(:,1))));
        else

            [~,tf]=inpolygon(obj.modifiedFeedLocations(:,1),obj.modifiedFeedLocations(:,2),obj.BoardShape.ShapeVertices(:,1),obj.BoardShape.ShapeVertices(:,2));
            if all(tf)
                isEdgeFed=true;
            else

                TR=triangulation(obj.BoardShape.InternalPolyShape);
                e=freeBoundary(TR);
                for i=1:size(obj.FeedLocations,1)
                    tf(i)=false;
                    [~,index]=em.MeshGeometry.findEdgeThroughPoint(TR.Points,e,obj.FeedLocations(i,1:2));
                    if~isempty(index)
                        tf(i)=true;
                    end
                end
                if all(tf)
                    isEdgeFed=true;
                end
            end
        end
    end

end