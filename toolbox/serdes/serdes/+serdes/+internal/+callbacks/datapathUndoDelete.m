





function datapathUndoDelete(block)
    tree=serdes.internal.callbacks.getSerDesTree(block);
    if~isempty(tree)
        blockName=get_param(block,'Name');
        tree.popUndoStack(blockName)
    end
end