

function dashboardBlockJumpToConnectedElementActionCB(cbinfo)
    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);
        if SLM3I.Util.isValidDiagramElement(element)
            if isa(element,'SLM3I.Block')
                editor=cbinfo.studio.App.getActiveEditor;
                utils.jumpToBoundElement(editor,element);
            end
        end
    end
end
