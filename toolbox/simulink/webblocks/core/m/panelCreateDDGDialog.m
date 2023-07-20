function obj=panelCreateDDGDialog(h,className)
    blockType=get_param(h,'BlockType');
    if strcmp(blockType,'PanelWebBlock')
        obj=panelwebblockdlgs.PanelWebBlock(h);
    end
end