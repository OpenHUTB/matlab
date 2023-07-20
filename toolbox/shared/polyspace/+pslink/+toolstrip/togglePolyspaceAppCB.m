function togglePolyspaceAppCB(userdata,callbackInfo)





    if isempty(callbackInfo.EventData)
        show=true;
    else
        show=callbackInfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);

    if isempty(app)
        return;
    end


    studio=callbackInfo.studio;
    sa=studio.App;
    acm=sa.getAppContextManager;

    if show
        alreadyActiveContext=acm.getCustomContext(app.name);
        if isempty(alreadyActiveContext)

            contextManager=pslink.toolstrip.PslinkContextManager();
            customContext=contextManager.getContext(callbackInfo.model.Handle);
            acm.activateApp(customContext);


            if isempty(callbackInfo.studio.App.getPinnedSystem('systemSelectionPolyspaceAction'))
                callbackInfo.studio.App.insertPinnedSystem('systemSelectionPolyspaceAction',...
                callbackInfo.model,Simulink.ID.getSID(callbackInfo.model.handle));
            end
        else

            ts=studio.getToolStrip;
            ts.ActiveTab=alreadyActiveContext.DefaultTabName;
        end
    else
        acm.deactivateApp(app.name);
    end
