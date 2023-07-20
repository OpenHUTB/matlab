function updateVisualizations(fov,viewer)








    fovGraphicID=fov.getGraphicID;
    if(~viewer.graphicExists(fovGraphicID))
        viewer.addGraphic(fovGraphicID,true);
    end

    addGraphicToClutterMap(fov,viewer);

    isFovVisible=viewer.getGraphicVisibility(fovGraphicID);
    if(~isFovVisible)
        return
    end



    if fov.ContourAvailabilityStatus

        contour=fov.Contour;



        locations=contour;


        for idx2=1:size(contour,1)
            itrfCoordinates=contour(idx2,:)';
            geographicCoordinates=...
            matlabshared.orbit.internal.Transforms.itrf2geographic(itrfCoordinates);
            locations(idx2,:)=[geographicCoordinates(1)*180/pi,...
            geographicCoordinates(2)*180/pi,0];
        end
        lineCollection(viewer.GlobeViewer,{locations},...
        'Width',fov.LineWidth,...
        'Color',fov.LineColor,...
        'Animation','none',...
        'Indices',{{1}},...
        'ID',fovGraphicID);
    else


        remove(viewer.GlobeViewer,fovGraphicID);
    end
end


