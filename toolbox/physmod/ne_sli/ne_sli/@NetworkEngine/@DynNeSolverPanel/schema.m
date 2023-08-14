function schema







    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hCreateInPackage.findclass('PmNeSolverPanel');


    hThisClass=schema.class(hCreateInPackage,'DynNeSolverPanel',hBaseObj);






    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};
