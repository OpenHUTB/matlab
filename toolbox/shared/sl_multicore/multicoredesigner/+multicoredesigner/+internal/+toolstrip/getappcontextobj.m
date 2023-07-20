function appcontextobj=getappcontextobj(cbinfo)





    modelH=cbinfo.model.Handle;
    if slfeature('SLMulticore')==0

        appcontextobj=multicoredesigner.internal.MulticoreContextManager.getContext(modelH);
    else

        acm=cbinfo.studio.App.getAppContextManager;
        appcontextobj=acm.getCustomContext('multicoreDesignerApp');
    end
end


