function out=HWDevice(cs,name,direction,widgetVals)




    hh=targetrepository.getHardwareImplementationHelper();

    if~isa(cs,'Simulink.ConfigSet')&&~isa(cs,'Simulink.HardwareCC')
        cs=getConfigSet(cs);
    end

    if direction==0
        if isempty(cs)
            out={'',''};
            return;
        end
        value=cs.get_param(name);
        device=hh.getDevice(value);

        if isempty(device)
            nameStruct=targetrepository.splitHWParameterString(value);
            if isempty(nameStruct)
                device=hh.getDevice('Specified');
            else
                out={nameStruct.Vendor,nameStruct.Type};
                return;
            end
        end

        if isempty(device.Manufacturer)
            vendorName=device.Name;
        else
            vendorName=device.Manufacturer;
        end

        out={vendorName,device.Name};

    elseif direction==1
        vendorName=widgetVals{1};
        typeName=widgetVals{2};

        if isempty(cs)
            out='';
            return;
        end
        oldValue=cs.get_param(name);
        oldDevice=hh.getDevice(oldValue);
        if~isempty(oldDevice)&&(strcmp(oldDevice.Manufacturer,vendorName)||...
            (isempty(oldDevice.Manufacturer)&&strcmp(oldDevice.Name,vendorName)))
            out=[vendorName,'->',typeName];
        else
            prefix=name(1:strfind(name,'HWDeviceType')-1);
            nameList={hh.getDevices(prefix,vendorName).Name};
            index=find(strcmp(typeName,nameList));
            if isempty(index)
                out=[vendorName,'->',nameList{1}];
            else
                out=[vendorName,'->',nameList{index}];
            end
        end

        if strcmp(name,'TargetHWDeviceType')||strcmp(cs.get_param('ProdEqTarget'),'on')


            adp=configset.internal.getConfigSetAdapter(cs);
            adp.toolchainInfo=[];
        end
    end


