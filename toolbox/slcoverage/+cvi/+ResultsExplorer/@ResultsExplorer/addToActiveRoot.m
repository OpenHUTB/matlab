
function addToActiveRoot(obj,data)




    if isempty(data)
        return;
    end
    if~obj.getOptions.enableCumulative&&...
        ~isempty(obj.root.activeTree.root.children)
        cvi.ResultsExplorer.ResultsExplorer.activeNode(obj.root.activeTree.root,obj.topModelName);
        cvi.ResultsExplorer.ResultsExplorer.clearCallback(obj.topModelName);
    end
    node=addToPassiveRoot(obj,data);
    cvi.ResultsExplorer.ResultsExplorer.activeNode(node,obj.topModelName);
    cvi.ResultsExplorer.ResultsExplorer.addCallback(obj.topModelName);
    if~isempty(cvi.Informer.findInformer(obj.topModelName))
        obj.highlightChange(node,true);
    end
end