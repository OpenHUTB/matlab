function result=isShowTargetFrequencyTask(obj)


    if(obj.isIPCoreGen)
        if obj.isGenericIPPlatform

            result=true;
        else
            hClockModule=obj.getClockModule;
            if~isempty(hClockModule)
                result=hClockModule.ShowTask;
            else
                result=false;
            end
        end
    else
        result=true;
    end

end
