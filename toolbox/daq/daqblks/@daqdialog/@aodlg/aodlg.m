function obj=aodlg(hBlock)





    obj=daqdialog.aodlg(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;



    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.SampleRate=obj.Block.SampleRate;
    obj.ActualRate=obj.Block.ActualRate;
    obj.NChannelsSelected=obj.Block.NChannelsSelected;
    obj.Channels=obj.Block.Channels;
    obj.NPorts=obj.Block.NPorts;
    obj.ModuleInfo=obj.Block.ModuleInfo;