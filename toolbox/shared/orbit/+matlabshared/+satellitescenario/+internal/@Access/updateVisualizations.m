function updateVisualizations(ac,viewer)








    acGraphicID=ac.getGraphicID;
    if(~viewer.graphicExists(acGraphicID))
        viewer.addGraphic(acGraphicID,true);
    end

    isAcVisible=viewer.getGraphicVisibility(acGraphicID);
    if(~isAcVisible)
        return
    end


    lineColor=ac.LineColor;
    lineWidth=ac.LineWidth;


    status=ac.pStatus;


    sequence=[{ac.Parent},ac.SequenceHandle];

    for idx2=1:numel(sequence)-1
        if status



            source=sequence{idx2};
            target=sequence{idx2+1};


            sourcePositionGeographic=...
            [source.pLatitude,source.pLongitude,source.pAltitude];
            targetPositionGeographic=...
            [target.pLatitude,target.pLongitude,target.pAltitude];
            locations=[sourcePositionGeographic;targetPositionGeographic];



            line(viewer.GlobeViewer,locations,...
            'Width',lineWidth,...
            'Color',lineColor,...
            'Animation','none',...
            'Dashed',true,...
            'DashLength',8,...
            'ID',ac.AccessGraphic{idx2});
        else

            remove(viewer.GlobeViewer,ac.AccessGraphic{idx2});
        end
    end
end

