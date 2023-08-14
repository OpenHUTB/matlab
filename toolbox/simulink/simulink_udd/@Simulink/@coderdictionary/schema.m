function schema




    mlock;



    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    dummy=findclass(hCreateInPackage,'document');
    dummy=findclass(hCreateInPackage,'directory');


    hThisClass=schema.class(hCreateInPackage,'coderdictionary',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'DisplayName','ustring');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'ModelName','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'ModelHandle','double');
    hThisProp.FactoryValue=0;




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

    m=schema.method(hThisClass,'initializeAndStart');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'showInME');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
