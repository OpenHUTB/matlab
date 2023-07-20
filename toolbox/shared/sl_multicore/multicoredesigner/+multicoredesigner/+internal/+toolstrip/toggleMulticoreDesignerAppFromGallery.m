


function toggleMulticoreDesignerAppFromGallery(userdata,cbinfo)

    if slfeature('SLMulticore')==0
        return
    end

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end


    c=dig.Configuration.get();
    app=c.getApp(userdata);
    if isempty(app)
        return;
    end


    modelH=cbinfo.model.Handle;
    acm=cbinfo.studio.App.getAppContextManager;


    if show
        context=acm.getCustomContext(app.name);
        if isempty(context)
            context=multicoredesigner.internal.MulticoreDesignerContext(app,modelH);
        end
        acm.activateApp(context);
    else
        acm.deactivateApp(app.name);
    end


    appmgr=multicoredesigner.internal.UIManager.getInstance();
    appmgr.initPerspective();
    isOn=appmgr.isPerspectiveEnabled(modelH);
    if show~=isOn
        appmgr.togglePerspective(modelH)
    end
end


