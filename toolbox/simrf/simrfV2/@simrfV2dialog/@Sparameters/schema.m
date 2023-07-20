function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'Visual');
    this=schema.class(rfPackage,'Sparameters',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'DataSource','SimRFV2DataSourceType');
    schema.prop(this,'File','string');
    schema.prop(this,'Paramtype','SimRFV2ParamType');
    schema.prop(this,'isNetworkObj','bool');
    schema.prop(this,'NetworkObject','string');
    schema.prop(this,'Sparam','string');
    schema.prop(this,'SparamFreq','string');
    schema.prop(this,'SparamZ0','string');
    schema.prop(this,'SparamFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'SparamRepresentation','SimRFV2SparamRepresentationType');
    schema.prop(this,'isRationalObj','bool');
    schema.prop(this,'RationalObject','string');
    schema.prop(this,'Residues','string');
    schema.prop(this,'Poles','string');
    schema.prop(this,'DF','string');
    schema.prop(this,'FitOpt','SimRFV2FitOptType');
    schema.prop(this,'FitTol','string');
    schema.prop(this,'MaxPoles','string');
    schema.prop(this,'AddNoise','bool');
    schema.prop(this,'InternalGrounding','bool');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'MagModeling','bool');

