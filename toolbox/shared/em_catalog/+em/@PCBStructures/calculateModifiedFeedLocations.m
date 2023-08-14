function modifiedfeedlocs=calculateModifiedFeedLocations(obj)
    if size(obj.FeedLocations,2)==4
        fullLayerMap=obj.FeedLocations(:,3:4);
    else
        fullLayerMap=obj.FeedLocations(:,3);
    end
    truelayermap=calculateTrueLayerMappings(obj,fullLayerMap);
    modifiedfeedlocs=[obj.FeedLocations(:,1:2),truelayermap];
end