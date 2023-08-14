function schema







    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'basetline');
    this=schema.class(rfPackage,'RLCG',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};





    if isempty(findtype('InterpMethodType'))
        schema.EnumType('InterpMethodType',{...
        'Linear',...
        'Spline',...
        'Cubic'});
    end

    schema.prop(this,'R','string');
    schema.prop(this,'L','string');
    schema.prop(this,'C','string');
    schema.prop(this,'G','string');
    schema.prop(this,'ParamFreq','string');
    schema.prop(this,'InterpMethod','InterpMethodType');


