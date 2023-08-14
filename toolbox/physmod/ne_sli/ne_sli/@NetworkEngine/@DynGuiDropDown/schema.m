function schema







    hBasePackage=findpackage('NetworkEngine');
    hBaseObj=hBasePackage.findclass('PmGuiDropDown');
    hCreateInPackage=hBasePackage;


    hThisClass=schema.class(hCreateInPackage,'DynGuiDropDown',hBaseObj);






    m=schema.method(hThisClass,'OnDropDownChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','mxArray','string'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'PreDlgDisplay');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

