function this=PanelWebBlock(block)
    this=panelwebblockdlgs.PanelWebBlock(block);
    if isa(block,'double')
        block=get_param(block,'object');
    end
    this.blockObj=block;