

function this=SwitchBlock(block)

    this=hmiblockdlg.SwitchBlock(block);
    this.init(block);
    this.widgetType='switch';
end

