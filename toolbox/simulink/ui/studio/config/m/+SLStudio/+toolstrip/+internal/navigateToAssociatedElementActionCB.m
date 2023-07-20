

function navigateToAssociatedElementActionCB(cbinfo)
    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);
        if SLM3I.Util.isValidDiagramElement(element)&&isa(element,'SLM3I.Block')
            editor=cbinfo.studio.App.getActiveEditor();
            aohc=editor.getAssociatedObjectHighlighterClient();
            if~isempty(aohc)
                aohc.doNavigate(element,element.center);
            end
        end
    end
end
