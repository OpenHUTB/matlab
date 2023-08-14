
function values=parseArguments(args)
    mt=mtree(['[',args,']']);
    node=mt.root;


    [hasNode,node]=slci.mlutil.getMtreeChildren(node);

    assert(hasNode==1);
    node=node{1};

    [hasNode,node]=slci.mlutil.getMtreeChildren(node);

    assert(hasNode==1);
    rowNodes=node;
    values={};

    for k=1:numel(rowNodes)
        [hasNode,node]=slci.mlutil.getMtreeChildren(rowNodes{k});

        assert(hasNode==1);

        for i=1:numel(node)
            values{end+1}=tree2str(node{i});%#ok
        end
    end
end
