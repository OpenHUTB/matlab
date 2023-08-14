function save(obj)




    if~isempty(obj)

        hasFilter=false;
        if~isempty(obj.filterExplorer)
            hasFilter=obj.filterExplorer.hasFilters();
        end
        if~obj.maps.uniqueIdMap.isempty||hasFilter

            activeTree=obj.root.activeTree.root;
            if~isempty(activeTree)&&~isempty(activeTree.children)
                activeTree.parentTree.removeTree(activeTree);



                if~obj.isClosing
                    obj.refreshTreeView;
                end
            end

            if obj.explorer.isVisible
                obj.saveObj;
            end
        end
    end
end