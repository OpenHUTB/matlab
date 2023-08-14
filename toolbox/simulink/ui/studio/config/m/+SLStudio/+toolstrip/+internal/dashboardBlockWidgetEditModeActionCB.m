

function dashboardBlockWidgetEditModeActionCB(cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);
        if SLM3I.Util.isValidDiagramElement(element)
            block=get_param(element.handle,'Object');
            if isprop(block,'Configuration')
                editor=cbinfo.studio.App.getActiveEditor();
                if(isempty(editor))
                    return
                end


                if(BindMode.utils.isBindModeEnabled(cbinfo.model.name))
                    BindMode.BindMode.disableBindMode(cbinfo.model);
                end

                SLM3I.SLDomain.setWidgetEditModeForEditor(editor,block.handle,logical(cbinfo.EventData));
            end
        end
    end
end
