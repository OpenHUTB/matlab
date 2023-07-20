function schema






mlock

    hCreateInPackage=findpackage('Simulink');
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomCC');
    hThisClass=schema.class(hCreateInPackage,'SoftwareTargetCC',hDeriveFromClass);


    m=schema.method(hThisClass,'getName');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'string'};


    m=schema.method(hThisClass,'isVisible');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle'};
    m.signature.OutputTypes={'bool'};


    m=schema.method(hThisClass,'skipModelReferenceComparison');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
