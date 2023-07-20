function showBlock(blockPath)
    block=get_param(blockPath,'Handle');
    parent=get_param(get_param(block,'Parent'),'Handle');

    previousSelectedBlocks=lutdesigner.access.internal.getSelectedBlocksInSystem(parent);
    arrayfun(@(x)set_param(x,'Selected','off'),previousSelectedBlocks);

    open_system(parent,'tab');
    set_param(parent,'CurrentBlock',block);
    set_param(block,'Selected','on');
end
