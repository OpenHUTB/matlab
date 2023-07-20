function enablePipeliningRefresher(cbinfo,action)


    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end

    modelH=cbinfo.model.Handle;
    mfModel=get_param(modelH,'MulticoreDataModel');
    mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);

    if mc.constraint.enablePipelining
        action.selected=true;
    else
        action.selected=false;
    end

end


