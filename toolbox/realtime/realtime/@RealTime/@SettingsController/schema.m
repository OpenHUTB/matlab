function schema()





    parentPkg=findpackage('Simulink');
    parentClass=findclass(parentPkg,'CustomCC');

    package=findpackage('RealTime');
    hthisClass=schema.class(package,'SettingsController',parentClass);

    p=add_prop(hthisClass,'TargetExtensionData','MATLAB array');
    p.FactoryValue='';

    p=add_prop(hthisClass,'TargetExtensionPlatform','string');
    p.FactoryValue='None';

    m=schema.method(hthisClass,'getName');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'string'};

    m=schema.method(hthisClass,'targetSelectionCallback');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','string'};
    m.Signature.OutputTypes={};

    m=schema.method(hthisClass,'widgetChanged');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','string'};
    m.Signature.OutputTypes={};

    m=schema.method(hthisClass,'getPropsThatAffectChecksum');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};

    function p=add_prop(h,name,type)
        p=Simulink.TargetCCProperty(h,name,type);
        p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

