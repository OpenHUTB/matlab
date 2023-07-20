function updateVisualizations(sat,viewer)








    satGraphicID=sat.getGraphicID;
    if(~viewer.graphicExists(satGraphicID))
        viewer.addGraphic(satGraphicID,true);
    end


    isSatVisible=viewer.getGraphicVisibility(satGraphicID);

    if isSatVisible

        showLabel=sat.pShowLabel;
        labelFontSize=sat.pLabelFontSize;
        labelFontColor=sat.pLabelFontColor;
        markerColor=sat.pMarkerColor;
        markerSize=sat.pMarkerSize;


        satGeographic=[sat.pLatitude,sat.pLongitude,sat.pAltitude];
        satName=string(sat.Name);


        label(viewer.GlobeViewer,satName,satGeographic,...
        "Color",labelFontColor,...
        "Font","Arial",...
        "FontSize",labelFontSize,...
        "InitiallyVisible",showLabel,...
        "ID",sat.LabelGraphic);


        point(viewer.GlobeViewer,satGeographic,...
        'Color',markerColor,...
        'Size',markerSize,...
        'Name',satName,...
        'Animation','none',...
        'ShowTooltip',true,...
        'OutlineWidth',1,...
        'LinkedGraphic',sat.LabelGraphic,...
        'ID',satGraphicID);
    end



    if strcmp(viewer.Dimension,'3D')
        updateVisualizations(sat.Orbit,viewer);
    else
        viewer.setGraphicVisibility(sat.Orbit.getGraphicID,false);
    end



    if~isempty(sat.GroundTrack)
        gt=sat.GroundTrack;
        if strcmp(gt.VisibilityMode,'auto')&&strcmp(viewer.Dimension,'3D')



            viewer.setGraphicVisibility(gt.getGraphicID,false);
        else
            updateVisualizations(sat.GroundTrack,viewer);
        end
    end


    for idx=1:numel(sat.ConicalSensors)
        updateVisualizations(sat.ConicalSensors(idx),viewer);
    end


    for idx=1:numel(sat.Gimbals)
        updateVisualizations(sat.Gimbals(idx),viewer);
    end


    for idx=1:numel(sat.Transmitters)
        updateVisualizations(sat.Transmitters(idx),viewer);
    end


    for idx=1:numel(sat.Receivers)
        updateVisualizations(sat.Receivers(idx),viewer);
    end


    for idx=1:numel(sat.Accesses)
        updateVisualizations(sat.Accesses(idx),viewer);
    end

    acs=matlabshared.satellitescenario.ScenarioGraphic.getAllRelatedAccesses(sat);
    for idx=1:numel(acs)
        updateVisualizations(acs(idx),viewer);
    end
end


