function schema






    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'basetline');
    this=schema.class(rfPackage,'TransmissionLine',parent);


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

    schema.prop(this,'Z0','string');
    schema.prop(this,'PV','string');
    schema.prop(this,'Loss','string');
    schema.prop(this,'ParamFreq','string');
    schema.prop(this,'InterpMethod','InterpMethodType');


