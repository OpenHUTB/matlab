function schema





    package=findpackage('dvfixptddg');
    parent=findclass(package,'DataTypeRow');
    this=schema.class(package,'DataTypeRowBestPrec',parent);



    schema.prop(this,'ParamBlock','handle');
    schema.prop(this,'ParamPropNames','string vector');
    schema.prop(this,'WordLengthOffset','double');
    schema.prop(this,'BestPrecString','ustring');
    schema.prop(this,'FracLengthEdit','ustring');

    m=schema.method(this,'updateFracLengthFromFracLength');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};

    m=schema.method(this,'updateFracLengthsFromSlope');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};

    m=schema.method(this,'hasPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(this,'getPropertyActions');
    m.signature.varargin='off';
    m.signature.InputTypes={'handle','string','ustring'};
    m.signature.OutputTypes={'mxArray'};
