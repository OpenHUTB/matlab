function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmEditUnit');


    hThisClass=schema.class(hCreateInPackage,'DynEditUnit',hBaseObj);





    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


