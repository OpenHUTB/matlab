function updateVisualizations(sensor,viewer)








    sensorGraphicID=sensor.getGraphicID;
    if(~viewer.graphicExists(sensorGraphicID))
        viewer.addGraphic(sensorGraphicID,true);
        sensor.hideGraphicIfParentInvisible(sensor.Parent,viewer);
    end


    isSensorVisible=viewer.getGraphicVisibility(sensorGraphicID);

    if isSensorVisible

        markerColor=sensor.pMarkerColor;
        markerSize=sensor.pMarkerSize;


        sensorGeographic=[sensor.pLatitude,sensor.pLongitude,sensor.pAltitude];


        sensorName=string(sensor.Name);
        point(viewer.GlobeViewer,sensorGeographic,...
        'Color',markerColor,...
        'Size',markerSize,...
        'Name',sensorName,...
        'Animation','none',...
        'DisplayDistance',1000,...
        'ID',sensorGraphicID);
    end



    if~isempty(sensor.FieldOfView)
        updateVisualizations(sensor.FieldOfView,viewer);
    end


    for idx=1:numel(sensor.Accesses)
        updateVisualizations(sensor.Accesses(idx),viewer);
    end

    acs=matlabshared.satellitescenario.ScenarioGraphic.getAllRelatedAccesses(sensor);
    for idx=1:numel(acs)
        updateVisualizations(acs(idx),viewer);
    end
end

