function schema









    hSuperPackage=findpackage('DAStudio');
    hSuperClass=findclass(hSuperPackage,'Object');
    hPackage=findpackage('AUTOSAR');
    hThisClass=schema.class(hPackage,'Tip',hSuperClass);




    schema.prop(hThisClass,'Explorer','handle');





    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getHeaderLabels');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(hThisClass,'getHeaderOrder');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string vector'};
    s.OutputTypes={'string vector'};
