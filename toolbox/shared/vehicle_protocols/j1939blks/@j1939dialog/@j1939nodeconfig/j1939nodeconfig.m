function obj=j1939nodeconfig(hBlock)

    obj=j1939dialog.j1939nodeconfig(hBlock);


    if isa(hBlock,'double')
        hBlock=get_param(hBlock,'object');
    end
    obj.Block=hBlock;


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.ConfigName=obj.Block.ConfigName;
    obj.NodeID=obj.Block.NodeID;
    obj.NodeName=obj.Block.NodeName;
    obj.NodeAddress=obj.Block.NodeAddress;
    obj.IndustryGroup=obj.Block.IndustryGroup;
    obj.VehicleSystem=obj.Block.VehicleSystem;
    obj.VehicleSystemInstance=obj.Block.VehicleSystemInstance;
    obj.FunctionID=obj.Block.FunctionID;
    obj.FunctionInstance=obj.Block.FunctionInstance;
    obj.ECUInstance=obj.Block.ECUInstance;
    obj.ManufacturerCode=obj.Block.ManufacturerCode;
    obj.IDNumber=obj.Block.IDNumber;
    obj.SampleTime=obj.Block.SampleTime;

    obj.AllowAAC=strcmpi(obj.Block.AllowAAC,'on');
    obj.OutputAddress=strcmpi(obj.Block.OutputAddress,'on');
    obj.OutputACStatus=strcmpi(obj.Block.OutputACStatus,'on');
    obj.ShowError=true;