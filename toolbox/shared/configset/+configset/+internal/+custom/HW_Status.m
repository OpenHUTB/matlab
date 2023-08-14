function[status,dscr]=HW_Status(cs,name)





    mlock;
    persistent saved_device saved_settings;

    dscr='Hardware pane parameters status';
    status=configset.internal.data.ParamStatus.Normal;


    if strcmp(cs.getProp('TargetUnknown'),'on')
        if strncmp(name,'Target',6)||strcmp(name,'ProdEqTarget')
            status=configset.internal.data.ParamStatus.InAccessible;
            return;
        end
    end

    if strncmp(name,'Prod',4)
        isTarget=false;
        device=cs.getProp('ProdHWDeviceType');
        valType=name(5:end);
    elseif strcmp(name,'TargetHWDeviceType')
        isTarget=true;
        device=cs.getProp('TargetHWDeviceType');
        valType=name(7:end);
    elseif strncmp(name,'Target',6)
        isTarget=true;
        device=cs.getProp('TargetHWDeviceType');
        valType=name(7:end);
    end

    if isTarget
        equal=cs.getProp('ProdEqTarget');
    end



    if isTarget&&strcmp(equal,'on')
        status=configset.internal.data.ParamStatus.ReadOnly;

    else


        if strcmp(name,'TargetHWDeviceType')
            status=configset.internal.data.ParamStatus.Normal;
            return;
        end


        hh=targetrepository.getHardwareImplementationHelper();

        if isequal(device,saved_device)
            RawHWSettings=saved_settings;
        else
            saved_device=device;
            RawHWSettings=getViewModelStructureForDevice(hh,device);
            saved_settings=RawHWSettings;
        end



        if isempty(RawHWSettings)
            HWSettings=getViewModelStructureForDevice(hh,'Specified');
        else
            HWSettings=RawHWSettings;
        end


        if strcmp(name,'ProdEqTarget')
            if(HWSettings.Platform==target.internal.compatibility.HardwareImplementationPlatform.All||...
                HWSettings.Platform==target.internal.compatibility.HardwareImplementationPlatform.Target)
                status=configset.internal.data.ParamStatus.Normal;
            else
                status=configset.internal.data.ParamStatus.ReadOnly;
            end
            return;
        end

        if HWSettings.isFPGA
            status=configset.internal.data.ParamStatus.InAccessible;
        else

            if contains(valType,HWSettings.InvisibleParams)
                status=configset.internal.data.ParamStatus.InAccessible;
            elseif~contains(valType,HWSettings.EnabledParams)
                status=configset.internal.data.ParamStatus.ReadOnly;
            else
                status=configset.internal.data.ParamStatus.Normal;
            end
        end
    end
end

function viewModelStructure=getViewModelStructureForDevice(hh,device)

    repositoryDevice=hh.getDevice(device);

    if isempty(repositoryDevice)
        viewModelStructure=[];
        return;
    end

    viewModelStructure.isFPGA=isa(repositoryDevice,'target.internal.FPGA');
    viewModelStructure.Platform=repositoryDevice.Platform;

    if~viewModelStructure.isFPGA
        implementation=hh.getImplementation(repositoryDevice);
        viewModelStructure.InvisibleParams=implementation.InvisibleParams.toArray();
        viewModelStructure.EnabledParams=implementation.EnabledParams.toArray();

        if isempty(viewModelStructure.InvisibleParams)
            viewModelStructure.InvisibleParams={};
        end

        if isempty(viewModelStructure.EnabledParams)
            viewModelStructure.EnabledParams={};
        end
    end
end
