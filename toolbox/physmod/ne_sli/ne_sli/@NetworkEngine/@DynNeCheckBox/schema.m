function schema







    hBasePackage=findpackage('NetworkEngine');
    hBaseObj=hBasePackage.findclass('PmNeCheckBox');
    hCreateInPackage=hBasePackage;


    hThisClass=schema.class(hCreateInPackage,'DynNeCheckBox',hBaseObj);






    m=schema.method(hThisClass,'OnCheckBoxChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','mxArray','string'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'PreDlgDisplay');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

