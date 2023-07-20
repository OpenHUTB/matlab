function devices=sortDevicesByComputeMode()
























    devices.SupportedDefaultIdx=[];
    devices.SupportedExclusiveIdx=[];
    devices.BestUnsupportedDefaultIdx=[];
    devices.BestUnsupportedExclusiveIdx=[];
    unsupportedDevicesComputeCap=[];
    unsupportedDevicesComputeMode=[];
    nSupportedDevices=0;
    unsupportedDevices=[];

    numDevices=gpuDeviceCount;

    if numDevices==0


        return
    end

    for idxDevice=1:numDevices

        gd=parallel.gpu.GPUDevice.getDevice(idxDevice);
        if gd.DeviceSupported
            nSupportedDevices=nSupportedDevices+1;
            switch gd.ComputeMode
            case 'Default'
                devices.SupportedDefaultIdx=...
                [devices.SupportedDefaultIdx,idxDevice];
            case{'Exclusive thread','Exclusive process'}
                devices.SupportedExclusiveIdx=...
                [devices.SupportedExclusiveIdx,idxDevice];
            end
        else
            unsupportedDevices=[unsupportedDevices,idxDevice];%#ok<AGROW>




            computeCapability=str2double(strsplit(gd.ComputeCapability,'.'));
            unsupportedDevicesComputeCap=...
            [unsupportedDevicesComputeCap;computeCapability];%#ok<AGROW>

            unsupportedDevicesComputeMode=...
            [unsupportedDevicesComputeMode;string(gd.ComputeMode)];%#ok<AGROW>
        end
    end
    if nSupportedDevices==0




        maxComputeCapability=sortrows(unsupportedDevicesComputeCap,'descend');
        maxUnsupportedComputeCapIdx=...
        unsupportedDevicesComputeCap(:,1)==maxComputeCapability(1,1)&...
        unsupportedDevicesComputeCap(:,2)==maxComputeCapability(1,2);
        unsupportedDevWithMaxComputeCap=unsupportedDevices(maxUnsupportedComputeCapIdx);
        unsupportedDevWithMaxComputeCapMode=unsupportedDevicesComputeMode(maxUnsupportedComputeCapIdx);

        unsupportedDefautIdx=...
        strcmp(unsupportedDevWithMaxComputeCapMode,'Default');
        devices.BestUnsupportedDefaultIdx=unsupportedDevWithMaxComputeCap(unsupportedDefautIdx);
        unsupportedExclusiveIdx=...
        strcmp(unsupportedDevWithMaxComputeCapMode,'Exclusive thread')|...
        strcmp(unsupportedDevWithMaxComputeCapMode,'Exclusive process');
        devices.BestUnsupportedExclusiveIdx=unsupportedDevWithMaxComputeCap(unsupportedExclusiveIdx);
    end
