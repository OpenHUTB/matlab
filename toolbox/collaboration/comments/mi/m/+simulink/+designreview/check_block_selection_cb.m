function isBlock=check_block_selection_cb(~)

    isBlock='false';
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(studios)
        studio=studios(1);
        activeEditor=studio.App.getActiveEditor;
        if~isempty(activeEditor)
            selection=activeEditor.getSelection;
            if(selection.size==1)
                sb=selection.front;
                if(isa(sb,'SLM3I.Block')&&SLM3I.Util.isValidDiagramElement(sb))
                    isBlock='true';
                end
            end
        end
    end
end
