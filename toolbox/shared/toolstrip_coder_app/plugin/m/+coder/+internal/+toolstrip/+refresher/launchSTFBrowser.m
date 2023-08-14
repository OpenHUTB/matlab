function launchSTFBrowser(cbInfo,action)




    mdl=cbInfo.studio.App.getActiveEditor.blockDiagramHandle;
    cs=getActiveConfigSet(mdl);



    if isa(cs,'Simulink.ConfigSetRef')
        action.enabled=false;
    end