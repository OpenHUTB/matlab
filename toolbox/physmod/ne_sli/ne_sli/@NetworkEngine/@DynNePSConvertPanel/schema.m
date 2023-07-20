function schema








    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hCreateInPackage.findclass('PmNePSConvertPanel');


    hThisClass=schema.class(hCreateInPackage,'DynNePSConvertPanel',hBaseObj);






    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};




