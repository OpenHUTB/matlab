function schema







    mlock;



    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'EditorPrefs',hDeriveFromClass);



    hThisProp=schema.prop(hThisClass,'NOBROWSER','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'URL','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SimulinkHandle','double');
    hThisProp.FactoryValue=0;



    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getFullName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

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

    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};


    m=schema.method(hThisClass,'dlgCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};



