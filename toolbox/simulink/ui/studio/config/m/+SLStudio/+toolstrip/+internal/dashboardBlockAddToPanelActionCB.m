

function dashboardBlockAddToPanelActionCB(cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
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
                    editor=cbinfo.studio.App.getActiveEditor();

                    elements=cell(1);
                    elements{1}=element;

                    promoteBlocksToWebPanel(editor,elements);
                end
            end
        end
    end
end
