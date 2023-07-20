function obj=tcpipsb(hBlock)





    obj=instrumentdialog.tcpipsb(hBlock);

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
    obj.EnableBlockingMode=strcmpi(obj.Block.EnableBlockingMode,'on');
    obj.Timeout=obj.Block.Timeout;
    obj.ByteOrder=obj.Block.ByteOrder;
    obj.TransferDelay=strcmpi(obj.Block.TransferDelay,'on');