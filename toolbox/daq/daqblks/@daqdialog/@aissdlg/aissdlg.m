function obj=aissdlg(hBlock)





    obj=daqdialog.aissdlg(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.ModuleInfo=obj.Block.ModuleInfo;
    obj.NChannelsSelected=obj.Block.NChannelsSelected;
    obj.Channels=obj.Block.Channels;
    obj.NPorts=obj.Block.NPorts;
    obj.BlockSampleTime=obj.Block.BlockSampleTime;
    obj.OutputTimeStamp=strcmpi(obj.Block.OutputTimestamp,'on');

