function s=getSyntaxes(modelName)


    s=sysarch.syntax.architecture.BoxPipeSyntax.empty;

    modelH=get_param(modelName,'Handle');
    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelH);
    if~isempty(appMgr)
        s(1)=appMgr.getSyntax();

        s(2)=appMgr.getArchViewsAppMgr.getSyntax;
    end
end
