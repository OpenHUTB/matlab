function nodes=findDOMTextNodes(container,searchPattern)










    nodes={};
    children=container.Children;
    nChildren=numel(children);

    for i=1:nChildren
        node=children(i);
        if isa(node,"mlreportgen.dom.Text")&&...
            contains(node.Content,searchPattern)
            nodes=[nodes,{node}];%#ok<AGROW>
        end
        nodes=[nodes...
        ,mlreportgen.utils.internal.findDOMTextNodes(node,searchPattern)];%#ok<AGROW>
    end
end
