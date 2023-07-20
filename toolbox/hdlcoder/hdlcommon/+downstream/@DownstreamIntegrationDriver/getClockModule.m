function hClockModule=getClockModule(obj)







    if obj.isIPCoreGen
        hRD=obj.hIP.getReferenceDesignPlugin;
        if isempty(hRD)
            if obj.isGenericIPPlatform
                hObj=obj.hTurnkey.hBoard;
            else
                hObj=[];
            end
        else
            hObj=hRD;
        end
    elseif obj.isGenericWorkflow
        hObj=obj.hGeneric;
    elseif~isempty(obj.hTurnkey)
        hObj=obj.hTurnkey.hBoard;
    else
        hObj=[];
    end


    if isempty(hObj)
        hClockModule=[];
    else
        hClockModule=hObj.hClockModule;
    end

end