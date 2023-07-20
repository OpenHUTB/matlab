

function dashboardBlockAddToPanelActionRF(cbinfo,action)
    action.enabled=false;
    editor=cbinfo.studio.App.getActiveEditor();
    if SLM3I.SLDomain.getWidgetEditModeForEditor(editor)
        return;
    end

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);


        if SLM3I.Util.isValidDiagramElement(element)
            if isa(element,'SLM3I.Block')
                block=get_param(element.handle,'Object');
                if isprop(block,'PanelInfo')&&...
                    isempty(get_param(block.handle,'PanelInfo'))
                    action.enabled=true;
                end
            end
        end
    end
end
