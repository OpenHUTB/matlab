
function this=EditField(block)
    this=hmiblockdlg.EditField(block);
    this.init(block);
    this.widgetType='editfield';
end