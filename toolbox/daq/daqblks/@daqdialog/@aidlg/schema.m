function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('daqdialog');


    hThisClass=schema.class(package,'aidlg',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'DeviceMenu','string');
    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'EnableApplyButtonAtInit','bool');
    schema.prop(hThisClass,'AcqMode','string');
    schema.prop(hThisClass,'ModuleInfo','string');
    schema.prop(hThisClass,'ObjConstructor','string');
    schema.prop(hThisClass,'SampleRate','string');
    schema.prop(hThisClass,'ActualRate','string');
    schema.prop(hThisClass,'ScansPerTrigger','string');
    schema.prop(hThisClass,'NChannelsSelected','string');
    schema.prop(hThisClass,'Channels','string');
    schema.prop(hThisClass,'NPorts','string');
    schema.prop(hThisClass,'OutputTimestamp','bool');
    schema.prop(hThisClass,'OutputTriggertime','bool');

    schema.prop(hThisClass,'ChannelsSchema','handle vector');


    schema.prop(hThisClass,'DAQObject','MATLAB array');
    schema.prop(hThisClass,'ChannelInfoList','MATLAB array');
    schema.prop(hThisClass,'subSystemType','string');


    schema.prop(hThisClass,'ObjectBeingDestroyedListener','MATLAB array');
    schema.prop(hThisClass,'PropertyChangedListener','MATLAB array');

