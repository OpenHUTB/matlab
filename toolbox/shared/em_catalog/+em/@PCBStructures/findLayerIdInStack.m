function[indxFeedLoc,indxViaLoc]=findLayerIdInStack(obj,indx)

    layerNums=1:numel(obj.Layers);
    metalLayerIndx=layerNums(cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers));
    thisLayer=metalLayerIndx(indx);
    if size(obj.FeedLocations,2)==4
        indxFeedLoc1=find(obj.FeedLocations(:,3)==thisLayer);
        indxFeedLoc2=find(obj.FeedLocations(:,4)==thisLayer);
        indxFeedLoc=[indxFeedLoc1;indxFeedLoc2];
    else
        indxFeedLoc=find(obj.FeedLocations(:,3)==thisLayer);
    end

    if~isempty(obj.ViaLocations)
        indxViaLoc1=find(obj.ViaLocations(:,3)==thisLayer);
        indxViaLoc2=find(obj.ViaLocations(:,4)==thisLayer);
        indxViaLoc=[indxViaLoc1;indxViaLoc2];
    else
        indxViaLoc=[];
    end

