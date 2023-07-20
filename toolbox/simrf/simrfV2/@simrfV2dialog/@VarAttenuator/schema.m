function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'VarAttenuator',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'Attmin','string');
    schema.prop(this,'Attmax','string');
    schema.prop(this,'Zin','string');
    schema.prop(this,'Zout','string');
    schema.prop(this,'AddNoise','bool');
    schema.prop(this,'InternalGrounding','bool');

