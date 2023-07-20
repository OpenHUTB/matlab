



function toggleAppCB(userdata,cbinfo)

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);
    if~isempty(app)
        context=dig.CustomContext(app);
        studio=cbinfo.studio;
        contextManager=studio.App.getAppContextManager;

        if show

            loc_deactivateMutuallyExclusiveApp(userdata,contextManager);

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

function loc_deactivateMutuallyExclusiveApp(tabName,contextManager)

    switch tabName
    case 'doQualKitApp'
        loc_deactivateApp('iecCertKitApp',contextManager);
    case 'iecCertKitApp'
        loc_deactivateApp('doQualKitApp',contextManager);
    end
end

function loc_deactivateApp(tabName,contextManager)

    if~isempty(contextManager.getCustomContext(tabName))
        contextManager.deactivateApp(tabName);
    end
end
