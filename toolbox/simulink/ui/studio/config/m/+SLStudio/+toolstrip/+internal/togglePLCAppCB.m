



function togglePLCAppCB(userdata,cbinfo)

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);
    if~isempty(app)
        context=PLCCoder.PLCToolstripContext(app);
        studio=cbinfo.studio;
        contextManager=studio.App.getAppContextManager;

        if show
            customContext=contextManager.getCustomContext(userdata);
            if isempty(customContext)

                contextManager.activateApp(context);
            else

                ts=studio.getToolStrip;
                ts.ActiveTab=customContext.DefaultTabName;
            end
        else
            contextManager.deactivateApp(app.name);
        end
    end
end
