function obj=udpsb(hBlock)





    obj=instrumentdialog.udpsb(hBlock);

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
    obj.EnableBlockingMode=strcmpi(obj.Block.EnableBlockingMode,'on');
    obj.ByteOrder=obj.Block.ByteOrder;
    obj.OutputDatagramPacketSize=obj.Block.OutputDatagramPacketSize;
    obj.EnablePortSharing=strcmpi(obj.Block.EnablePortSharing,'on');