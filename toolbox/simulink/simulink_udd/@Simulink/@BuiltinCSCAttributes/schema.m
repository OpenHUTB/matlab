function schema()






mlock



    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'BaseCSCAttributes');
    hCreateInPackage=findpackage('Simulink');



    hThisClass=schema.class(hCreateInPackage,'BuiltinCSCAttributes',hDeriveFromClass);

    hMethod=schema.method(hThisClass,'disp');
    s=hMethod.signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    hMethod=schema.method(hThisClass,'writeContentsForSaveVars','static');
    s=hMethod.signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


