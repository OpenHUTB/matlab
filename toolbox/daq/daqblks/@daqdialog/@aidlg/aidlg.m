function obj=aidlg(hBlock)





    obj=daqdialog.aidlg(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.AcqMode=obj.Block.AcqMode;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.SampleRate=obj.Block.SampleRate;
    obj.ActualRate=obj.Block.ActualRate;
    obj.ScansPerTrigger=obj.Block.ScansPerTrigger;
    obj.NChannelsSelected=obj.Block.NChannelsSelected;
    obj.Channels=obj.Block.Channels;
    obj.NPorts=obj.Block.NPorts;
    obj.OutputTimestamp=strcmpi(obj.Block.OutputTimestamp,'on');
    obj.OutputTriggertime=strcmpi(obj.Block.OutputTriggertime,'on');
    obj.ModuleInfo=obj.Block.ModuleInfo;