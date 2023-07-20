function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'SubSysNode');
    cls=schema.class(findpackage('SigLogSelector'),'BdNode',sCls);


    p=schema.prop(cls,'delayCallback','bool');
    p.FactoryValue=false;


    p=schema.prop(cls,'timestampDeltaQueue','MATLAB array');
    p.FactoryValue=[];


    p=schema.prop(cls,'lastTimestamp','MATLAB array');
    p.FactoryValue=[];


    p=schema.prop(cls,'callbackTimer','MATLAB array');
    p.FactoryValue=[];


    p=schema.prop(cls,'isClosing','bool');
    p.FactoryValue=false;




    p=schema.prop(cls,'skipAllPropChangeEvents','bool');
    p.FactoryValue=false;


    m=schema.method(cls,'addTimestampDeltaToQueue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'double'};



    m=schema.method(cls,'loadObject');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


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


    m=schema.method(cls,'setOverrideMode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
    s.OutputTypes={};


    m=schema.method(cls,'getOverrideMode');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    p=schema.prop(cls,'logAsSpecifiedInMdl','SigLogSelectorTriStateEnum');
    p.FactoryValue='unchecked';
    p.GetFunction=@getLogAsSpecifiedInMdl;

end


