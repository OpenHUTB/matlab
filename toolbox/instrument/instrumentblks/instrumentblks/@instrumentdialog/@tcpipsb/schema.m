function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('instrumentdialog');

    hThisClass=schema.class(package,'tcpipsb',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'Host','string');
    schema.prop(hThisClass,'Port','string');
    schema.prop(hThisClass,'EnableBlockingMode','bool');
    schema.prop(hThisClass,'Timeout','string');
    schema.prop(hThisClass,'ByteOrder','string');
    schema.prop(hThisClass,'TransferDelay','bool');
