function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('instrumentdialog');

    hThisClass=schema.class(package,'udprb',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'Host','string');
    schema.prop(hThisClass,'Port','string');
    schema.prop(hThisClass,'LocalPort','string');
    schema.prop(hThisClass,'LocalAddress','string');
    schema.prop(hThisClass,'GetLatestData','bool');
    schema.prop(hThisClass,'DataSize','string');
    schema.prop(hThisClass,'EnableBlockingMode','bool');
    schema.prop(hThisClass,'Timeout','string');
    schema.prop(hThisClass,'SampleTime','string');
    schema.prop(hThisClass,'DataType','string');
    schema.prop(hThisClass,'ASCIIFormatting','string');
    schema.prop(hThisClass,'Terminator','string');
    schema.prop(hThisClass,'ByteOrder','string');
    schema.prop(hThisClass,'EnablePortSharing','bool');

