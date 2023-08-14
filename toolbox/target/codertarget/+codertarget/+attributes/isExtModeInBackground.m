function out=isExtModeInBackground(hObj)




    if~isa(hObj,'Simulink.ConfigSet')
        hObj=getActiveConfigSet(hObj);
    end
    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if targetInfo.EnableOneClick
        extMode=targetInfo.ExternalModeInfo;
        extModeTaskInfo=[];
        if isscalar(extMode)
            extModeTaskInfo=extMode.Task;
        else
            out=false;
            data=codertarget.data.getData(hObj);
            for i=1:numel(extMode)
                if isequal(extMode(i).Transport.IOInterfaceName,data.ExtMode.Configuration)
                    extModeTaskInfo=extMode(i).Task;
                    break;
                end
            end
        end
        if isempty(extModeTaskInfo)
            DAStudio.error('codertarget:targetapi:InvalidExternalModeIOInterface',data.ExtMode.Configuration);
        end
        if extModeTaskInfo.InBackground&&extModeTaskInfo.InForeground
            out=codertarget.attributes.getExtModeData('RunInBackground',hObj);
        elseif extModeTaskInfo.InBackground
            out=true;
        elseif extModeTaskInfo.InForeground
            out=false;
        else
            assert(false);
        end
    else
        out=false;
    end
end
