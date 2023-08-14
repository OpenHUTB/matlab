function[opData,idx]=getModelOperationData(this,mdl)





    idx=this.findModelEntry(mdl);

    if~isempty(idx)

        opData=this.modelInfo(idx).modelOperation;

    else


























        this.registerModel(mdl);
        idx=this.findModelEntry(mdl);
        if isempty(idx)
            configData=RtmModelRegistry_config;
            pm_error(configData.Error.ModelNotRegistered_templ_msgid,mdl.Name);
        end
        opData=this.modelInfo(idx).modelOperation;

    end



