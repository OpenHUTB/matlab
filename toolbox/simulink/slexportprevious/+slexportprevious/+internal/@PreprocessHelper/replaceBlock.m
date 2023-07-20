function replaceBlock(~,block,replacementBlock,varargin)






    orient=get_param(block,'Orientation');
    pos=get_param(block,'Position');
    commented=get_param(block,'Commented');

    delete_block(block);
    add_block(replacementBlock,block,...
    'Orientation',orient,...
    'Position',pos,...
    'Commented',commented,...
    varargin{:});

end