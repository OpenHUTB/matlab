function treeExpandedCallback(obj,tree)




    if~tree.isActive&&...
        tree.resultsExplorer.explorer.isVisible
        obj.loadAllData;
    end
end