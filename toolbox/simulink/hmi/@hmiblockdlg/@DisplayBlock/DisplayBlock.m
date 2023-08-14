

function this=DisplayBlock(block)

    this=hmiblockdlg.DisplayBlock(block);
    this.init(block);
    this.widgetType='displayblock';
end