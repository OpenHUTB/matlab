function obj=aossdlg(hBlock)





    obj=daqdialog.aossdlg(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.NChannelsSelected=obj.Block.NChannelsSelected;
    obj.Channels=obj.Block.Channels;
    obj.NPorts=obj.Block.NPorts;
    obj.ModuleInfo=obj.Block.ModuleInfo;
    obj.BlockSampleTime=obj.Block.BlockSampleTime;