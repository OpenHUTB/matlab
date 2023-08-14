function tf=isHierarchyReadonly(~,node)




    tf=false;
    if isa(node,'cvi.ResultsExplorer.Node')&&...
        node.data.invalid
        tf=true;
    end
end