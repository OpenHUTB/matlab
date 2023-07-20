function schema




    hCreateInPackage=findpackage('RTW');
    hBaseClass=findclass(hCreateInPackage,'FcnCtlUI');

    hThisClass=schema.class(hCreateInPackage,'CPPFcnCtlUI',hBaseClass);




    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};


    m=schema.method(hThisClass,'FunctionClassChanged');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double','handle'};
    s.OutputTypes={};
