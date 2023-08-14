function feedloc=calculateFeedLocation(obj)

    layer_heights=calculateLayerZCoords(obj);
    feedloc=obj.modifiedFeedLocations(:,1:2);


    feedloc(:,3)=layer_heights(obj.modifiedFeedLocations(:,3));


    if size(obj.FeedLocations,2)>3
        [~,ef]=obj.checkEdgeFeed;


        feedloc(~ef,3)=layer_heights(obj.modifiedFeedLocations(~ef,4));






    end

end