function[out,dscr]=CodeReplacementLibrary_entries(cs,~,opt_addCurrent)



    if nargin<=2
        addCurrentSelectedLibrary=true;
    else
        addCurrentSelectedLibrary=opt_addCurrent;
    end

    dscr='CodeReplacementLibrary enum option is dynamic generated.';

    tr=RTW.TargetRegistry.get;

    if isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end

    if isempty(config)
        registeredTfls=coder.internal.getTflNameList(tr,'nonSim',cs);
    else
        hw=config.getComponent('Hardware Implementation');
        hh=targetrepository.getHardwareImplementationHelper();
        hwDevice=hh.getDevice(hw.ProdHWDeviceType);

        if isempty(hwDevice)
            nameStruct=targetrepository.splitHWParameterString(hw.ProdHWDeviceType);
            if isempty(nameStruct)
                VendorName='';
                DeviceType='';
            else
                VendorName=nameStruct.Vendor;
                DeviceType=nameStruct.Type;
            end
        else
            VendorName=hwDevice.Manufacturer;
            DeviceType=hwDevice.Name;
            if isempty(VendorName)
                VendorName=hwDevice.Name;
            end
        end

        hSrc=config.getComponent('Code Generation').getComponent('Target');
        registeredTfls=coder.internal.getTflList4Target(tr,VendorName,DeviceType,hSrc);

        if addCurrentSelectedLibrary
            currentCRL=coder.internal.getCrlLibraries(hSrc.CodeReplacementLibrary);
            len=length(currentCRL);
            for i=1:len
                if~strcmpi(currentCRL{i},'none')
                    try


                        fullCurrentName=coder.internal.getTfl(tr,currentCRL{i}).Name;
                        if~ismember(fullCurrentName,registeredTfls)
                            registeredTfls=[registeredTfls;fullCurrentName];%#ok<AGROW>
                        end
                    catch


                        registeredTfls=[registeredTfls;currentCRL{i}];%#ok<AGROW>
                    end
                end
            end
        end
    end

    none_str='None';
    none_disp=message('RTW:configSet:CodeReplacementLibrary_None').getString;

    disps=[{none_disp};registeredTfls];
    strs=[{none_str};registeredTfls];
    out=struct('str',strs,'disp',disps);
