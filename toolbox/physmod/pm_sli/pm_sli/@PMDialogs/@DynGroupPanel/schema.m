function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGroupPanel');


    hThisClass=schema.class(hCreateInPackage,'DynGroupPanel',hBaseObj);





    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


