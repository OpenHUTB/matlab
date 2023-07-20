function turnOnPerspective(obj,input,extra)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(input);
    end

    if nargin<3
        extra=true;
    end

    studio=src.studio;


    ts=studio.getToolStrip;
    as=ts.getActionService;
    app=obj.getInfo(studio.App.blockDiagramHandle);
    if~isempty(app)
        appInfo=coder.internal.toolstrip.util.getAppInfo(app);
        as.executeActionSync(appInfo.action,extra);
    end
end
