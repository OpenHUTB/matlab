function schema








    hCreateInPackage=findpackage('NetworkEngine');
    hBaseObj=hCreateInPackage.findclass('PmNeComponentChooserPanel');


    hThisClass=schema.class(hCreateInPackage,...
    'DynNeComponentChooserPanel',hBaseObj);







    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};

    m=schema.method(hThisClass,'RefreshSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','ustring','ustring'};
    s.OutputTypes={};