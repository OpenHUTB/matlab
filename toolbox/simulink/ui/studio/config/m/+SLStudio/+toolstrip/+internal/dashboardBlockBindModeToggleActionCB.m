

function dashboardBlockBindModeToggleActionCB(cbinfo)
    if(BindMode.utils.isBindModeEnabled(cbinfo.model.name))
        BindMode.BindMode.disableBindMode(cbinfo.model);
        return;
    end

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);
        if SLM3I.Util.isValidDiagramElement(element)
            if isa(element,'SLM3I.Block')
                editor=cbinfo.studio.App.getActiveEditor();
                if(isempty(editor))
                    return
                end


                if SLM3I.SLDomain.getWidgetEditModeForEditor(editor)
                    SLM3I.SLDomain.setWidgetEditModeForEditor(editor,0,false);
                end







                utils.HMIBindMode.toggleBindMode(editor,element);
            end
        end
    end
end
