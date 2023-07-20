function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'SubSysNode');
    cls=schema.class(findpackage('SigLogSelector'),'SFObjectNode',sCls);


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getFullMdlRefPath');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

end
