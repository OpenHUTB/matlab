function schema()





    parentPkg=findpackage('Simulink');
    parentClass=findclass(parentPkg,'CustomCC');

    package=findpackage('pjtgeneratorpkg');
    hthisClass=schema.class(package,'TargetHardwareResources',parentClass);

    p=schema.prop(hthisClass,'TargetHardwareResources','MATLAB array');
    p.FactoryValue='';

    p=schema.prop(hthisClass,'TargetHardwareResourcesController','MATLAB array');
    p.FactoryValue=[];
    p.Visible='off';
    p.AccessFlags.Serialize='off';

    m=schema.method(hthisClass,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hthisClass,'isEditableProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.outputTypes={'bool'};

    m=schema.method(hthisClass,'isReadonlyProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.outputTypes={'bool'};
