function result=isEnabledTargetFrequency(obj)


    if(obj.isIPCoreGen)
        if obj.isGenericIPPlatform

            result=true;
        else
            hClockModule=obj.getClockModule;
            if~isempty(hClockModule)
                result=hClockModule.Adjustable;
            else
                result=false;
            end
        end
    else
        result=true;
    end

end
