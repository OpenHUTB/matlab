function schema








    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hCreateInPackage.findclass('PmNeDescriptionPanel');


    hThisClass=schema.class(hCreateInPackage,'DynNeDescriptionPanel',hBaseObj);




    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};

end
