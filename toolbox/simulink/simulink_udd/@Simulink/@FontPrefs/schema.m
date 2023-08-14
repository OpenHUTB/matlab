function schema






    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'FontPrefs',hDeriveFromClass);



    hThisProp=schema.prop(hThisClass,'NOBROWSER','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'URL','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SimulinkHandle','double');
    hThisProp.FactoryValue=-1;


    schema.prop(hThisClass,'DialogData','MATLAB array');



    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'controlCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'dlgCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={'bool','string'};



