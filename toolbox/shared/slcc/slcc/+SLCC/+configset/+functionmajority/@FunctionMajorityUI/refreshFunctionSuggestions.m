function refreshFunctionSuggestions(this)

    mdlH=this.configSet.getModel();
    if~isempty(mdlH)
        try
            slcc('parseCustomCode',mdlH);
        catch

            return;
        end
        this.functionSuggestions=slcc('getCanTakeMajorityFunctionList',mdlH);
    end