function datapathDelete(block)
    tree=serdes.internal.callbacks.getSerDesTree(block);
    if~isempty(tree)
        blockInstanceName=get_param(block,'Name');
        tree.removeBlock(blockInstanceName,true);

    end
end