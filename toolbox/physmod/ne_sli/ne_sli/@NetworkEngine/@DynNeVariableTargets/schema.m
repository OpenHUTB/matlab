function schema







    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hCreateInPackage.findclass('PmNeVariableTargets');


    hThisClass=schema.class(hCreateInPackage,'DynNeVariableTargets',hBaseObj);





    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};

    m=schema.method(hThisClass,'targetChangedCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','mxArray'};
    s.OutputTypes={};
