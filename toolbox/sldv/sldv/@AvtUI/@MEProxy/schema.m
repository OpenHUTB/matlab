function schema

    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hCreateInPackage=findpackage('AvtUI');
    hThisClass=schema.class(hCreateInPackage,'MEProxy',hDeriveFromClass);

    p=schema.prop(hThisClass,'coreObj','mxArray');
    p=schema.prop(hThisClass,'propProxyListeners','mxArray');
    p=schema.prop(hThisClass,'propRefreshDialogListeners','mxArray');
    p=schema.prop(hThisClass,'children','handle vector');

    m=schema.method(hThisClass,'add_property_listeners');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','mxArray','string','bool'};
    m.signature.OutputTypes={};

    m=schema.method(hThisClass,'cb_corePropChanged');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','mxArray','mxArray'};
    m.signature.OutputTypes={};

    m=schema.method(hThisClass,'cb_refreshDialog');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','mxArray','mxArray'};
    m.signature.OutputTypes={};

    function add_method(name,inTypes,outTypes)
        m=schema.method(hThisClass,name);
        s=m.Signature;
        s.varargin='off';
        s.InputTypes=inTypes;
        s.OutputTypes=outTypes;
    end

end