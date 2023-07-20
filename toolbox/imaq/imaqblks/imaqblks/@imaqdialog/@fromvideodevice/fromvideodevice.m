function obj=fromvideodevice(hBlock)








    obj=imaqdialog.fromvideodevice(hBlock);


    obj.Block=get_param(hBlock,'Object');


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    obj.Root=parent;

    origAdaptor=strtok(obj.Block.Device);
    newAdaptor=imaqgate('privateTranslateAdaptor',origAdaptor);


    obj.Device=strrep(obj.Block.Device,origAdaptor,newAdaptor);
    obj.DeviceMenu=strrep(obj.Block.DeviceMenu,origAdaptor,newAdaptor);
    obj.ObjConstructor=strrep(obj.Block.ObjConstructor,origAdaptor,newAdaptor);
    obj.VideoFormat=obj.Block.VideoFormat;
    obj.VideoFormatMenu=obj.Block.VideoFormatMenu;
    obj.CameraFile=obj.Block.CameraFile;
    obj.VideoSource=obj.Block.VideoSource;
    obj.ROIPosition=obj.Block.ROIPosition;
    obj.ROIHeight=obj.Block.ROIHeight;
    obj.ROIWidth=obj.Block.ROIWidth;
    obj.ROIRow=obj.Block.ROIRow;
    obj.ROIColumn=obj.Block.ROIColumn;
    obj.EnableHWTrigger=strcmpi(obj.Block.EnableHWTrigger,'on');
    obj.TriggerConfiguration=obj.Block.TriggerConfiguration;
    obj.SampleTime=obj.Block.SampleTime;
    obj.OutputPortsMode=obj.Block.OutputPortsMode;
    obj.DataType=obj.Block.DataType;
    obj.ReturnedColorSpace=obj.Block.ReturnedColorSpace;
    obj.ColorSpace=obj.Block.ColorSpace;
    obj.BayerSensorAlignment=obj.Block.BayerSensorAlignment;
    obj.CanDoHWTrigger=strcmpi(obj.Block.CanDoHWTrigger,'yes');
    obj.AllMetadata=obj.Block.AllMetadata;
    obj.SelectedMetadata=obj.Block.SelectedMetadata;
    obj.ImaqMode=strcmpi(obj.Block.ImaqMode,'on');


    obj.ShowErrorPopUp=true;
