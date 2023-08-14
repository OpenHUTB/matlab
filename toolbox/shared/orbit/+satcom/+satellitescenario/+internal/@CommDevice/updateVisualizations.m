function updateVisualizations(asset,viewer)








    assetGraphicID=getGraphicID(asset);
    if(~viewer.graphicExists(assetGraphicID))
        viewer.addGraphic(assetGraphicID,true);
        asset.hideGraphicIfParentInvisible(asset.Parent,viewer);
    end


    isAssetVisible=viewer.getGraphicVisibility(assetGraphicID);


    if isAssetVisible

        markerColor=asset.pMarkerColor;
        markerSize=asset.pMarkerSize;


        positionGeographic=...
        [asset.pLatitude,asset.pLongitude,asset.pAltitude];


        assetName=string(asset.Name);
        point(viewer.GlobeViewer,positionGeographic,...
        'Color',markerColor,...
        'Size',markerSize,...
        'Name',assetName,...
        'Animation','none',...
        'DisplayDistance',1000,...
        'ID',assetGraphicID);
    end

    if isa(asset,'satcom.satellitescenario.internal.Transmitter')
        for idx=1:numel(asset.Links)
            updateVisualizations(asset.Links(idx),viewer);
        end
    end

    lnks=getAllRelatedLinks(asset);
    for idx=1:numel(lnks)
        updateVisualizations(lnks(idx),viewer);
    end
    if(~isempty(asset.Pattern))
        updateVisualizations(asset.Pattern,viewer);
    end
end

