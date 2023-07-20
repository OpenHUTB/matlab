function schema









    hBasePackage=findpackage('NetworkEngine');
    hBaseObj=hBasePackage.findclass('DynNeDlgSource');
    hCreateInPackage=hBasePackage;


    cls=schema.class(hCreateInPackage,'DynNeUtilDlgSource',hBaseObj);





    m=schema.method(cls,'internalGetPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'internalValidateDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

