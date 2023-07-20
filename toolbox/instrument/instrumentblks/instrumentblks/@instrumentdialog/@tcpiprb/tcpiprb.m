function obj=tcpiprb(hBlock)





    obj=instrumentdialog.tcpiprb(hBlock);

    if isa(hBlock,'double')
        hBlock=get_param(hBlock,'Object');
    end


    obj.Block=hBlock;


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.Host=obj.Block.Host;
    obj.Port=obj.Block.Port;
    obj.DataSize=obj.Block.DataSize;
    obj.EnableBlockingMode=strcmpi(obj.Block.EnableBlockingMode,'on');
    obj.DataType=obj.Block.DataType;
    obj.ASCIIFormatting=obj.Block.ASCIIFormatting;
    obj.Terminator=obj.Block.Terminator;
    obj.ByteOrder=obj.Block.ByteOrder;
    obj.Timeout=obj.Block.Timeout;
    obj.SampleTime=obj.Block.SampleTime;
