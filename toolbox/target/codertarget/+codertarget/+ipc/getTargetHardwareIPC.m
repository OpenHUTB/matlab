function out=getTargetHardwareIPC(hObj)





    out=[];
    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end


    attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if isempty(attributeInfo.IPCInfoFiles)
        return;
    end
    defFiles=codertarget.utils.replaceTokens(hObj,attributeInfo.IPCInfoFiles{1},attributeInfo.Tokens);
    out=codertarget.ipc.IPCInfo(defFiles);