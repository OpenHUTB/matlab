function myDeviceIndex=defaultGPUIndex()



















    hMediator=parallel.internal.pool.GPUClusterMediator.getInstance();








    devices=parallel.internal.gpu.sortDevicesByComputeMode();



    if(~isempty(devices.BestUnsupportedDefaultIdx)||...
        ~isempty(devices.BestUnsupportedExclusiveIdx))
        unsupportedDevices=sort([devices.BestUnsupportedDefaultIdx,...
        devices.BestUnsupportedDefaultIdx]);
        myDeviceIndex=unsupportedDevices(1);
        return;
    end


    if(isempty(devices.SupportedDefaultIdx)&&...
        isempty(devices.SupportedExclusiveIdx))


        error(message('parallel:gpu:device:UnavailableDevice'));
    end


    nodeInfo=parallel.gpu.NodeInfo(hMediator,devices.SupportedDefaultIdx,...
    devices.SupportedExclusiveIdx);



    myDeviceIndex=selectGPU(nodeInfo);

end