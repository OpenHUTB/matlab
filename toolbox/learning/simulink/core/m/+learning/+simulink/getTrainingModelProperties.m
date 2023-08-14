function[modelName,editor,studio]=getTrainingModelProperties()

    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    studio={};

    for idx=1:numel(allStudios)

        if~isempty(allStudios(idx).getComponent('GLUE2:DDG Component',learning.simulink.StudioMgr.TASK_PANE_ID))
            studio=allStudios(idx);
            break
        end
    end

    if isempty(studio)
        modelName='';
        editor={};
        return
    end

    editor=studio.App.getActiveEditor;

    modelName=editor.getName;

end
