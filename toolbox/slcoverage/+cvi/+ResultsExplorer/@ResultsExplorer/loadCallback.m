function loadCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)
        obj=node.getExplorer;
        loadDataFromUI(obj,false);
    end
end