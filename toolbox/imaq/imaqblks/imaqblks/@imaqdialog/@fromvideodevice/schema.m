function schema







    parentPkg=findpackage('Simulink');
    parent=findclass(parentPkg,'SLDialogSource');
    package=findpackage('imaqdialog');
    hThisClass=schema.class(package,'fromvideodevice',parent);



    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('DataTypeEnum'))
        schema.EnumType('DataTypeEnum',...
        {'single',...
        'double',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32'});
    end

    if isempty(findtype('PortsModeEnum'))
        schema.EnumType('PortsModeEnum',...
        {'One multidimensional signal',...
        'Separate color signals'});
    end


    schema.prop(hThisClass,'DeviceMenu','string');
    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'ObjConstructor','string');
    schema.prop(hThisClass,'VideoFormatMenu','string');
    schema.prop(hThisClass,'VideoFormat','string');
    schema.prop(hThisClass,'CameraFile','string');
    schema.prop(hThisClass,'VideoSource','string');
    schema.prop(hThisClass,'ROIPosition','string');
    schema.prop(hThisClass,'EnableHWTrigger','bool');
    schema.prop(hThisClass,'TriggerConfiguration','string');
    schema.prop(hThisClass,'SampleTime','string');
    schema.prop(hThisClass,'OutputPortsMode','PortsModeEnum');
    schema.prop(hThisClass,'DataType','DataTypeEnum');
    schema.prop(hThisClass,'CanDoHWTrigger','bool');
    schema.prop(hThisClass,'ReturnedColorSpace','string');
    schema.prop(hThisClass,'ColorSpace','string');
    schema.prop(hThisClass,'BayerSensorAlignment','string');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'IsDifferentFormat','bool');
    schema.prop(hThisClass,'IsDifferentSource','bool');
    schema.prop(hThisClass,'IsUserDataInvalid','bool');
    schema.prop(hThisClass,'IsPreviewing','bool');
    schema.prop(hThisClass,'IsBeingInspected','bool');
    schema.prop(hThisClass,'ROIHeight','string');
    schema.prop(hThisClass,'ROIWidth','string');
    schema.prop(hThisClass,'ROIRow','string');
    schema.prop(hThisClass,'ROIColumn','string');
    schema.prop(hThisClass,'IsCallbackCalled','bool');
    schema.prop(hThisClass,'ObjectCreationFailed','bool');
    schema.prop(hThisClass,'ShowErrorPopUp','bool');
    schema.prop(hThisClass,'PropertyChangedListener','MATLAB array');
    schema.prop(hThisClass,'ObjectBeingDestroyedListener','MATLAB array');
    schema.prop(hThisClass,'AllMetadata','string');
    schema.prop(hThisClass,'SelectedMetadata','string');
    schema.prop(hThisClass,'ImaqMode','bool');


    schema.prop(hThisClass,'IMAQObject','MATLAB array');
