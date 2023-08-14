function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'SubSysNode');
    cls=schema.class(findpackage('SigLogSelector'),'SFChartNode',sCls);


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getSFChartObject','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(cls,'view');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

end
