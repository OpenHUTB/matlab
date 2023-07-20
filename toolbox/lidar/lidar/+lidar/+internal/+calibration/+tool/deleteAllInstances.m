
function deleteAllInstances()







    wwmInstance=matlab.internal.webwindowmanager.instance;
    if(isempty(wwmInstance))
        return;
    end
    toolTitle=string(message('lidar:lidarCameraCalibrator:appTitle'));
    list=[];

    for i=1:length(wwmInstance.windowList)
        if(~isempty(strfind(wwmInstance.windowList(i).Title,toolTitle)))
            list=[list,i];
        end
    end

    if(~isempty(list))
        delete(wwmInstance.windowList(list));
    end
end