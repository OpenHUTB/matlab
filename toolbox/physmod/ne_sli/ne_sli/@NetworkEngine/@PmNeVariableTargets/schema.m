function schema








    hBasePackage=findpackage('PMDialogs');
    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hBasePackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmNeVariableTargets',hBaseObj);


    schema.prop(hThisClass,'DefaultTargets','mxArray');


    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'Refresh');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};