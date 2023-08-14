function result=isShowCustomSWModelGenerationTask(obj)


    if obj.isIPWorkflow
        hRD=obj.hIP.getReferenceDesignPlugin;
        if~isempty(hRD)
            result=~isempty(hRD.CallbackSWModelGeneration);
        else
            result=false;
        end
    else
        result=false;
    end

end
