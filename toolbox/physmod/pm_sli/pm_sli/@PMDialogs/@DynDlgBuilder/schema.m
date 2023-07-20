function schema












    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmDlgBuilder');


    hThisClass=schema.class(hCreateInPackage,'DynDlgBuilder',hBaseObj);


    p=schema.prop(hThisClass,'BlockHandle','mxArray');


    m=schema.method(hThisClass,'Render');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};


