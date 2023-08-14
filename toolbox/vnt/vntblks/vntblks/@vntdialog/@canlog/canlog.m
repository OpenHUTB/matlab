function obj=canlog(hBlock)






    obj=vntdialog.canlog(hBlock);


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


    obj.FullPathFileName=obj.Block.FullPathFileName;
    obj.VariableName=obj.Block.VariableName;
    obj.MaxNumMessages=obj.Block.MaxNumMessages;
    obj.LogFrom=obj.Block.LogFrom;
    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.SampleTime=obj.Block.SampleTime;
