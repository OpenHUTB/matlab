function schema








    hCreateInPkg=findpackage('RTW');


    hBaseClass=findclass(hCreateInPkg,'TraceInfoBase');


    hThisClass=schema.class(hCreateInPkg,'TraceInfo',hBaseClass);


    hThisProp=schema.prop(hThisClass,'FileLineIndex','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.Visible='off';


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


