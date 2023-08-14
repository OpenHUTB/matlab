function schema()




mlock


    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'TargetCC');


    hThisClass=schema.class(hCreateInPackage,'CustomTargetCC',hDeriveFromClass);



    m=schema.method(hThisClass,'getTargetSpecificString');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'filterTlcOptions');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMdlRefComplianceTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','Sl_MdlRefTarget_EnumType'};
    s.OutputTypes={'MATLAB array'};



