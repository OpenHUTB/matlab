function turnOffPerspective(obj,input)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(input);
    end

    studio=src.studio;


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    cps=cp.getFlag(src.modelH,studio);
    if~isempty(cps)
        app=cps.app;
        ts=studio.getToolStrip;
        as=ts.getActionService;
        appInfo=coder.internal.toolstrip.util.getAppInfo(app);
        as.executeActionSync(appInfo.action,false);
    end
end


