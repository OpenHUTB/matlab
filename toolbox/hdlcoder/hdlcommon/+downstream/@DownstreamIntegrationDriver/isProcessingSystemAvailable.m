function result=isProcessingSystemAvailable(obj)





    if obj.isIPWorkflow
        hRD=obj.hIP.getReferenceDesignPlugin;
        if~isempty(hRD)
            result=hRD.HasProcessingSystem;
        else
            result=false;
        end
    else
        result=false;
    end

end