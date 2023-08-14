function obj=canfdreplay(hBlock)





    obj=vntdialog.canfdreplay(hBlock);


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
    obj.NoTimesReplay=obj.Block.NoTimesReplay;
    obj.ReplayTo=obj.Block.ReplayTo;
    obj.Device=obj.Block.Device;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.SampleTime=obj.Block.SampleTime;