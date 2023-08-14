

function this=LampBlock(block)

    this=hmiblockdlg.LampBlock(block);
    this.init(block);
    this.widgetType='lampblock';
    blockHandle=this.blockObj.Handle;
    this.DefaultColor=get_param(blockHandle,'DefaultColor');
    states=get_param(blockHandle,'States');
    this.States={};
    for idx=1:length(states{1})
        this.States{idx}=num2str(states{1}(idx),16);
    end
    this.StateColors=states{2};
    this.Icon=get_param(blockHandle,'Icon');
    this.CustomIcon=get_param(blockHandle,'CustomIcon');
    this.ApplyCustom=false;
    this.DisableApplyColorSlimDialog=false;
    this.InitialCustom=false;
    this.ApplyColorChange=false;
end
