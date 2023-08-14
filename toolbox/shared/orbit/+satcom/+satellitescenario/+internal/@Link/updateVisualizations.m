function updateVisualizations(lnk,viewer)








    lnkGraphicID=getGraphicID(lnk);
    if(~viewer.graphicExists(lnkGraphicID))
        viewer.addGraphic(lnkGraphicID,true);
    end

    isLnkVisible=viewer.getGraphicVisibility(lnkGraphicID);
    if(~isLnkVisible)
        return
    end


    lineColor=lnk.LineColor;
    lineWidth=lnk.LineWidth;


    status=lnk.pStatus;


    sequence=[{lnk.Parent},lnk.SequenceHandle];

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
            'Dashed',false,...
            'ID',lnk.LinkGraphic{idx2});
        else

            remove(viewer.GlobeViewer,lnk.LinkGraphic{idx2});
        end
    end
end

