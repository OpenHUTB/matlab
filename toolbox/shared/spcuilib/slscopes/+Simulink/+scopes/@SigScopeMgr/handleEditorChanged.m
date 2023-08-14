function handleEditorChanged(~,~,~)







    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if(~isempty(studios))
        studio=studios(1);
        studioApp=studio.App;
        activeEditor=studioApp.getActiveEditor;
        assert(~isempty(activeEditor));










        mdlName=get_param(activeEditor.blockDiagramHandle,'Name');
        Simulink.scopes.SigScopeMgr.showSigScopeMgrNavigation(studio,mdlName,activeEditor.blockDiagramHandle,[]);

    end
end