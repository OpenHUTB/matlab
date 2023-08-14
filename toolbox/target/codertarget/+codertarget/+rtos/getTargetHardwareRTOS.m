function rtosOut=getTargetHardwareRTOS(hObj)





    if ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    end
    hwInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    rtosOut=[];
    if~isempty(hwInfo)
        attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        if~isempty(attributeInfo)
            Tokens=attributeInfo.Tokens;
        else
            Tokens={};
        end
        defFiles=codertarget.utils.replaceTokens(hObj,hwInfo.RTOSInfoFiles,Tokens);
        if~isempty(defFiles)
            for i=1:numel(defFiles)
                rtos=codertarget.Registry.manageInstance('get','rtos',defFiles{i});
                data=codertarget.data.getData(hObj.getConfigSet());
                if~isfield(data,'RTOS')
                    rtosOut=rtos;
                    break;
                elseif isequal(rtos.Name,codertarget.targethardware.getTargetRTOS(hObj))
                    rtosOut=rtos;
                    break
                end
            end
        end
    end


