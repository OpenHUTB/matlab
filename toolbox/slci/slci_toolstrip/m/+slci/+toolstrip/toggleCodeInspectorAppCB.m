


function toggleCodeInspectorAppCB(userdata,cbinfo)

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);
    if~isempty(app)
        studio=cbinfo.studio;
        contextManager=studio.App.getAppContextManager;

        if show
            customContext=contextManager.getCustomContext(userdata);
            if isempty(customContext)
                context=slci.toolstrip.context.SLCIToolstripContext(app);

                context.updateAutomaticReviewTypeChain
                contextManager.activateApp(context);

                context.openApp(cbinfo);
            else

                ts=studio.getToolStrip;
                ts.ActiveTab=customContext.DefaultTabName;
            end
        else
            contextManager.deactivateApp(app.name);
            view=slci.view.Manager.getInstance;
            view.close(studio);

            mr=slci.manualreview.Manager.getInstance;
            mr.close(studio);
        end

    end
end