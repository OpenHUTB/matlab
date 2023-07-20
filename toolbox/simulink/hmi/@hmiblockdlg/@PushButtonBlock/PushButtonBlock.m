


function this=PushButtonBlock(block)
    this=hmiblockdlg.PushButtonBlock(block);
    this.init(block);
    this.widgetType='pushbutton';
    blockHandle=this.blockObj.Handle;
    this.IconOnColor=get_param(blockHandle,'IconOnColor');
    this.IconOffColor=get_param(blockHandle,'IconOffColor');
    this.Icon=get_param(blockHandle,'Icon');
    this.CustomIcon=get_param(blockHandle,'CustomIcon');
    this.ApplyCustom=false;
    this.InitialCustom=false;
end