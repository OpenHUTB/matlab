function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'AbstractNode');
    cls=schema.class(findpackage('SigLogSelector'),'SubSysNode',sCls);



    p=schema.prop(cls,'childNodes','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';



    schema.prop(cls,'signalChildren','handle vector');




    p=schema.prop(cls,'signalsPopulated','bool');
    p.FactoryValue=false;




    p=schema.prop(cls,'cachedHasSignals','SigLogHasLoggingEnum');
    p.FactoryValue='unknown';




    schema.prop(cls,'CachedFullName','ustring');





    p=schema.prop(cls,'SFObjectBeingAddedListeners','mxArray');
    p.AccessFlags.PublicGet='on';
    p.AccessFlags.PublicSet='on';



    p=schema.prop(cls,'logAsSpecified','bool');
    p.GetFunction=@getLogAsSpecified;


    m=schema.method(cls,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


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


    m=schema.method(cls,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};


    m=schema.method(cls,'getModelLoggingInfo');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(cls,'setModelLoggingInfo');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


    m=schema.method(cls,'showDialog');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

end
