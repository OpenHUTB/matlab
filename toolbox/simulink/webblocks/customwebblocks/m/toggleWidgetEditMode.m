
function toggleWidgetEditMode(model,blockHandle,flag)
    handle=get_param(model,'Handle');
    studios=SLM3I.SLDomain.getAllStudioAppsFor(handle);
    if isempty(studios)
        return;
    end
    elementHandle=-1;
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end



    try
        if isBlockInWebPanel(blockHandle)
            parentSystem=get_param(blockHandle,'Parent');
            modelDiagramPair=SLM3I.Util.getDiagram(parentSystem);
        end

        element=SLM3I.SLDomain.handle2DiagramElement(blockHandle);
        if(~isempty(element))
            elementHandle=element.handle;
        end
    catch ME





        assert(isequal(flag,0));
    end


    if BindMode.utils.isBindModeEnabled(handle)&&isequal(flag,1)
        BindMode.utils.disableBindMode(handle);
    end
    for studio=studios
        editors=studio.getAllEditors();
        if isempty(editors)
            continue;
        end
        for editor=editors

            if isequal(flag,1)
                editor.cancelSSATool();
            end

            SLM3I.SLCommonDomain.setWidgetEditModeForEditor(editor,elementHandle,flag);
        end
    end
end
