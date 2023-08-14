function setPcbStackFeedType(obj,isEdgeFed,localConnModel,Mesh)

    if size(obj.FeedLocations,2)>3
        if~isEdgeFed

            setFeedType(obj,'multiedge');



        else

            setFeedType(obj,'multiedge');
        end
    else
        setFeedType(obj,'singleedge');
    end
    if strcmpi(localConnModel,'strip')
        et=detectEdgeType(obj,Mesh.Points',Mesh.Triangles');
        setFeedType(obj,et);
    end