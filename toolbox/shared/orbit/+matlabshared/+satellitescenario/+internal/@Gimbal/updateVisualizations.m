function updateVisualizations(gim,viewer)








    gimbalGraphicID=gim.getGraphicID;
    if(~viewer.graphicExists(gimbalGraphicID))
        viewer.addGraphic(gimbalGraphicID,true);
        gim.hideGraphicIfParentInvisible(gim.Parent,viewer);
    end


    isGimbalVisible=viewer.getGraphicVisibility(gimbalGraphicID);

    if isGimbalVisible

        markerColor=gim.pMarkerColor;
        markerSize=gim.pMarkerSize;


        positionGeographic=[gim.pLatitude,gim.pLongitude,gim.pAltitude];


        gimbalName=string(gim.Name);
        point(viewer.GlobeViewer,positionGeographic,...
        'Color',markerColor,...
        'Size',markerSize,...
        'Name',gimbalName,...
        'Animation','none',...
        'DisplayDistance',1000,...
        'ID',gimbalGraphicID);
    end



    for idx=1:numel(gim.ConicalSensors)
        updateVisualizations(gim.ConicalSensors(idx),viewer);
    end


    for idx=1:numel(gim.Transmitters)
        updateVisualizations(gim.Transmitters(idx),viewer);
    end


    for idx=1:numel(gim.Receivers)
        updateVisualizations(gim.Receivers(idx),viewer);
    end
end

