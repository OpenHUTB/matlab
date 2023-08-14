function obj=diossdlg(hBlock)





    obj=daqdialog.diossdlg(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.IsDigitalInput=strcmpi(obj.Block.IsDigitalInput,'on');
    obj.Device=obj.Block.Device;
    obj.DeviceMenu=obj.Block.DeviceMenu;
    obj.ObjConstructor=obj.Block.ObjConstructor;
    obj.ModuleInfo=obj.Block.ModuleInfo;
    obj.NLinesSelected=obj.Block.NLinesSelected;
    obj.Lines=obj.Block.Lines;
    obj.NPorts=obj.Block.NPorts;
    obj.BlockSampleTime=obj.Block.BlockSampleTime;
    if obj.IsDigitalInput
        obj.OutputTimeStamp=strcmpi(obj.Block.OutputTimestamp,'on');
    end
