function clear(viewer,deleteCZMLFile)








    czmlFileID=viewer.CZMLFileID;



    viewer.GlobeViewer.Controller.RequestTimeout=Inf;
    cleanupObj=onCleanup(@()cleanupGlobeControllerTimeout(viewer));
    for idx=1:numel(czmlFileID)
        data=struct(...
        'ID',{{czmlFileID{idx}}},...
        'EnableDayNightLighting',true,...
        'ShowAnimationAndTimelineWidget',false,...
        'EnableWindowLaunch',true,...
        'Animation','none');
        viewer.GlobeViewer.Controller.visualRequest('remove',data);
    end


    if(deleteCZMLFile)
        viewer.CZMLFileID={};
    end



    if~isempty(viewer.CZMLFile)&&deleteCZMLFile
        for idx=1:numel(viewer.CZMLFile)
            if isfile(viewer.CZMLFile{idx})
                delete(viewer.CZMLFile{idx});
            end
        end
        viewer.CZMLFile={};
    end


    clear(viewer.GlobeViewer);
    viewer.GlobeViewer.Controller.RequestTimeout=120;
    viewer.Labels=struct("NeedsUpdate",false);
end
function cleanupGlobeControllerTimeout(viewer)
    viewer.GlobeViewer.Controller.RequestTimeout=120;
end

