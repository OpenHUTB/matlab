function obj=j1939cantl(hBlock)





    obj=vntdialog.j1939cantl(hBlock);


    if isa(hBlock,'double')
        obj.Block=get_param(hBlock,'Object');
    else
        obj.Block=hBlock;
    end


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.ConfigName=obj.Block.ConfigName;
    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.BusSpeedStr=obj.Block.BusSpeedStr;
    obj.SampleTime=obj.Block.SampleTime;