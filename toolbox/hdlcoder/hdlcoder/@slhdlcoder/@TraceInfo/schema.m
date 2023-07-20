function schema








    thisPkg=findpackage('slhdlcoder');


    basePkg=findpackage('RTW');


    hBaseClass=findclass(basePkg,'TraceInfoBase');


    hThisClass=schema.class(thisPkg,'TraceInfo',hBaseClass);




    hThisMethod=schema.method(hThisClass,'instance','static');

    m=schema.method(hThisClass,'getTraceInfoFileName');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getSInfoFileName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getCodeGenRptFileName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};
