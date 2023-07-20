function schema



    mlock;


    sCls=findclass(findpackage('SigLogSelector'),'AbstractObject');
    cls=schema.class(findpackage('SigLogSelector'),'LogSignalObj',sCls);




    schema.prop(cls,'signalInfo','mxArray');



    schema.prop(cls,'SourcePath','ustring');


    m=schema.method(cls,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.inputTypes={'handle'};
    s.OutputTypes={'string vector'};


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


    m=schema.method(cls,'isEditableProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};


    m=schema.method(cls,'getPropDataType');
    s=m.Signature;
    s.varargin='off';
    s.inputTypes={'handle','string'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getPropAllowedValues');
    s=m.Signature;
    s.varargin='off';
    s.inputTypes={'handle','string'};
    s.OutputTypes={'string vector'};


    m=schema.method(cls,'getPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'ustring'};


    m=schema.method(cls,'setPropValue');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','ustring'};
    s.OutputTypes={};


    m=schema.method(cls,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    m=schema.method(cls,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};


    m=schema.method(cls,'refreshSettings');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

end
