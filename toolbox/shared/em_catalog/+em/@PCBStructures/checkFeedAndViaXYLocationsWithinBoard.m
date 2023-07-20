function checkFeedAndViaXYLocationsWithinBoard(obj)



    bshape=obj.BoardShape;

    feedloc=obj.FeedLocations(:,1:2);
    [in,~]=contains(bshape,feedloc(:,1),feedloc(:,2));
    if any(~in)
        error(message('antenna:antennaerrors:XYLocationOutsideBoard','feed '));
    end

    if~isempty(obj.ViaLocations)
        vialoc=obj.ViaLocations(:,1:2);
        [in,~]=contains(bshape,vialoc(:,1),vialoc(:,2));
        if any(~in)
            error(message('antenna:antennaerrors:XYLocationOutsideBoard','via'));
        end
    end
end