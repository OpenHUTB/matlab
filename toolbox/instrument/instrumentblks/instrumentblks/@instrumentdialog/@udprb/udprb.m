function obj=udprb(hBlock)





    obj=instrumentdialog.udprb(hBlock);

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
    obj.LocalPort=obj.Block.LocalPort;
    obj.LocalAddress=obj.Block.LocalAddress;
    obj.GetLatestData=strcmpi(obj.Block.GetLatestData,'on');
    obj.DataSize=obj.Block.DataSize;
    obj.EnableBlockingMode=strcmpi(obj.Block.EnableBlockingMode,'on');
    obj.DataType=obj.Block.DataType;
    obj.ByteOrder=obj.Block.ByteOrder;
    obj.ASCIIFormatting=obj.Block.ASCIIFormatting;
    obj.Terminator=obj.Block.Terminator;
    obj.Timeout=obj.Block.Timeout;
    obj.SampleTime=obj.Block.SampleTime;
    obj.EnablePortSharing=strcmpi(obj.Block.EnablePortSharing,'on');
