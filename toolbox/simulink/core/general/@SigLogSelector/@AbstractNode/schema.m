function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'AbstractObject');
    cls=schema.class(findpackage('SigLogSelector'),'AbstractNode',sCls);


    m=schema.method(cls,'isHierarchyReadonly');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};


    m=schema.method(cls,'closeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

end
