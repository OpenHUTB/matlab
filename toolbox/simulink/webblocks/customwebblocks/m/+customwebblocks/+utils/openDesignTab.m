function openDesignTab(bdHandle,blockHandle,toggleWEM)
    if(~isnumeric(bdHandle))
        bdHandle=str2double(bdHandle);
    end
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    studios=SLM3I.SLDomain.getAllStudioAppsFor(bdHandle);
    for studio=studios
        editors=studio.getAllEditors();
        if isempty(editors)
            continue;
        end
        for editor=editors
            editorStudio=editor.getStudio;
            PI=editorStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            editorStudio.showComponent(PI);
            if PI.AllowMinimize
                PI.restore
            end
            inspector=PI.getInspector();
            if isBlockInWebPanel(blockHandle)
                inspector.setActiveTab(1);
            else
                inspector.setActiveTab(2);
            end
        end
    end
    if isequal(toggleWEM,true)
        model=get_param(bdHandle,'Name');
        toggleWidgetEditMode(model,blockHandle,toggleWEM);
    end
end