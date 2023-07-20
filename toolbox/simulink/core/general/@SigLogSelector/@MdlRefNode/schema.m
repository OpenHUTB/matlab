function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'SubSysNode');
    cls=schema.class(findpackage('SigLogSelector'),'MdlRefNode',sCls);



    schema.prop(cls,'hBdNode','handle');



    schema.prop(cls,'refModelInvalid','bool');


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};


    m=schema.method(cls,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};


    m=schema.method(cls,'getCheckableProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'isValidProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'isReadonlyProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'setPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','ustring'};
    s.OutputTypes={};


    m=schema.method(cls,'refModelClosed');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    p=schema.prop(cls,'logAsSpecifiedInMdl','SigLogSelectorTriStateEnum');
    p.FactoryValue='unchecked';
    p.GetFunction=@getLogAsSpecifiedInMdl;

end


