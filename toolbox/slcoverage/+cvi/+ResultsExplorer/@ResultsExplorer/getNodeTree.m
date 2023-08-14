function tree=getNodeTree(~,node)




    tree=0;
    if isa(node,'cvi.ResultsExplorer.Tree')
        tree=node;
    elseif isa(node,'cvi.ResultsExplorer.Node')
        tree=node.parentTree;
    end
end