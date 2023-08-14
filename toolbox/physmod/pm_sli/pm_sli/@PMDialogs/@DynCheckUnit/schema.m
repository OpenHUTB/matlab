function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmCheckUnit');


    hThisClass=schema.class(hCreateInPackage,'DynCheckUnit',hBaseObj);





    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


