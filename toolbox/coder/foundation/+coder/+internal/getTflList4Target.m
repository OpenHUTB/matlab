function tflList=getTflList4Target(lTargetRegistry,vendorName,deviceType,hSrc)



    if nargin~=4
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    end


    refreshCRL(lTargetRegistry);


    Entries=coder.internal.getTflNameList(lTargetRegistry,'nonSim',hSrc);
    if strcmp(vendorName,'Generic')==1||...
        strcmp(vendorName,'Custom Processor')==1
        tflList=Entries;
        return;
    end

    tflList={};
    hh=targetrepository.helpers.HardwareImplementation(targetrepository.create());
    for i=1:length(Entries)
        tfl=coder.internal.getTfl(lTargetRegistry,Entries{i});
        if(ismember('*',tfl.TargetHWDeviceType))
            tflList=[tflList;Entries{i}];
        else
            HWTypes=tfl.TargetHWDeviceType;
            for j=1:length(HWTypes)
                SupportedHw=hh.getDevice(HWTypes{j});
                if isempty(SupportedHw)
                    continue;
                end
                supportedVendor=SupportedHw.Manufacturer;
                supportedDeviceType=SupportedHw.Name;
                if isempty(supportedVendor)
                    supportedVendor=SupportedHw.Name;
                end

                if strcmp(supportedVendor,vendorName)&&strcmp(supportedDeviceType,deviceType)
                    tflList=[tflList;Entries{i}];
                    break;
                end
            end
        end
    end


