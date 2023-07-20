function schema





    package=findpackage('dvfixptddg');
    parent=findclass(package,'DataTypeRow');
    this=schema.class(package,'DataTypeRowFractional',parent);

    schema.prop(this,'BestPrecString','ustring');
    schema.prop(this,'NumIntegerBits','double');
    schema.prop(this,'isSigned','bool');
    schema.prop(this,'SignedText','ustring');
    schema.prop(this,'SignednessVisible','ustring');

    m=schema.method(this,'hasPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(this,'getPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string','ustring'};
    m.signature.OutputTypes={'mxArray'};

