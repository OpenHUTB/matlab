function updateVisualizations(gs,viewer)








    gsGraphicID=gs.getGraphicID;
    if(~viewer.graphicExists(gsGraphicID))
        viewer.addGraphic(gsGraphicID,true);
    end


    isGsVisible=viewer.getGraphicVisibility(gsGraphicID);

    if isGsVisible

        showLabel=gs.ShowLabel;
        labelFontSize=gs.LabelFontSize;
        labelFontColor=gs.LabelFontColor;
        markerColor=gs.MarkerColor;
        markerSize=gs.MarkerSize;


        location=[gs.Latitude,gs.Longitude,gs.Altitude];
        gsName=gs.Name;

        label(viewer.GlobeViewer,gsName,location,...
        "Color",labelFontColor,...
        "Font","Arial",...
        "FontSize",labelFontSize,...
        "InitiallyVisible",showLabel,...
        "ID",gs.LabelGraphic);

        point(viewer.GlobeViewer,location,...
        'Name',gsName,...
        'Color',markerColor,...
        'Size',markerSize,...
        'ShowTooltip',true,...
        'Animation','none',...
        'OutlineWidth',1,...
        'LinkedGraphic',gs.LabelGraphic,...
        'ID',gsGraphicID);
    end



    for idx=1:numel(gs.ConicalSensors)
        updateVisualizations(gs.ConicalSensors(idx),viewer);
    end


    for idx=1:numel(gs.Gimbals)
        updateVisualizations(gs.Gimbals(idx),viewer);
    end


    for idx=1:numel(gs.Transmitters)
        updateVisualizations(gs.Transmitters(idx),viewer);
    end


    for idx=1:numel(gs.Receivers)
        updateVisualizations(gs.Receivers(idx),viewer);
    end


    for idx=1:numel(gs.Accesses)
        updateVisualizations(gs.Accesses(idx),viewer);
    end

    acs=matlabshared.satellitescenario.ScenarioGraphic.getAllRelatedAccesses(gs);
    for idx=1:numel(acs)
        updateVisualizations(acs(idx),viewer);
    end
end

