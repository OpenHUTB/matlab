function schema




    mlock;



    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DVOutput',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'DisplayName','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'ModelName','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'BuildTime','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'isOutofDate','bool');
    hThisProp.FactoryValue=0;
    hThisProp=schema.prop(hThisClass,'dummyToggle','bool');
    hThisProp.FactoryValue=0;
    hThisProp=schema.prop(hThisClass,'HTMLText','string');
    hThisProp.FactoryValue='';
    schema.prop(hThisClass,'parent','mxArray');


    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'getFullName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getParent');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'enableMEMenuItem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'showInME');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
