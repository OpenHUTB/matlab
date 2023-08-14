function customContext=getExpectedCoderAppContext(model)




    src=simulinkcoder.internal.util.getSource(model);
    studio=src.studio;

    customContext=[];

    ts=studio.getToolStrip;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [app,~,lang]=cp.getInfo(studio.App.blockDiagramHandle);
    appInfo=coder.internal.toolstrip.util.getAppInfo(app);

    if~isempty(appInfo)
        contextManager=studio.App.getAppContextManager;
        customContext=contextManager.getCustomContext(appInfo.appName);
    end
end

