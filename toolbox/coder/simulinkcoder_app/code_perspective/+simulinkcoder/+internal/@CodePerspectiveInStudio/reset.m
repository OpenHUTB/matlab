function reset(obj)





    obj.setupModelListeners();

    if~obj.active
        return;
    end

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if coderdictionary.data.feature.getFeature('CodeGenIntent')
        cp.reset(obj.studio);
    end


    studio=obj.studio;
    top=studio.App.blockDiagramHandle;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [app,~,lang]=cp.getInfo(top);
    appChanged=~strcmp(app,obj.app);
    if appChanged

        appInfo=coder.internal.toolstrip.util.getAppInfo(obj.app);
        stf=get_param(top,'SystemTargetFile');
        msg=message('SimulinkCoderApp:codeperspective:ClosedByTargetChange',...
        appInfo.disp,stf).getString;
        notifyKey='CoderAppClosedByTargetChange';
        editor=studio.App.getActiveEditor;
        editor.deliverInfoNotification(notifyKey,msg);
        cp.turnOffPerspective(studio);
    else
        cp.reset(obj.studio);
        obj.appLang=lang;
    end


