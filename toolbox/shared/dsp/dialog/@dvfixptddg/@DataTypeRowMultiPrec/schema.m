function schema





    package=findpackage('dvfixptddg');
    parent=findclass(package,'DataTypeRow');
    this=schema.class(package,'DataTypeRowMultiPrec',parent);

    schema.prop(this,'ParamBlock','handle');
    schema.prop(this,'ParamFuncName','ustring');
    schema.prop(this,'NumPrecs','int');
    schema.prop(this,'PropNames','string vector');
    schema.prop(this,'MaskPropNames','string vector');
    schema.prop(this,'SlopeTags','string vector');

    m=schema.method(this,'updateFracLengthNFromSlopeN');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string'};

    m=schema.method(this,'hasPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(this,'getPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string','ustring'};
    m.signature.OutputTypes={'mxArray'};

