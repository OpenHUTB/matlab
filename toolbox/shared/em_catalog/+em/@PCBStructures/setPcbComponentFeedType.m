function setPcbComponentFeedType(obj,isEdgeFed,localConnModel,Mesh)

    if size(obj.FeedLocations,2)>3
        if~all(isEdgeFed)

            setFeedType(obj,'multiedge');



        else
            if strcmpi(localConnModel,'multi-strip')
                setFeedType(obj,'multiedge');
            else
                setFeedType(obj,'singleedge');
            end
        end
    else
        if strcmpi(localConnModel,'multi-strip')
            setFeedType(obj,'multiedge');
        else
            setFeedType(obj,'singleedge');
        end
    end





