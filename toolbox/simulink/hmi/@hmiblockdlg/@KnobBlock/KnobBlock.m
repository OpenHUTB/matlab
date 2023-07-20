


function this=KnobBlock(block)
    this=hmiblockdlg.KnobBlock(block);
    this.init(block);
    this.widgetType='knob';
end
