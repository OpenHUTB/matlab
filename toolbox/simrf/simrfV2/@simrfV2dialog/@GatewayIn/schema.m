function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'GatewayIn',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'SimulinkInputSignalType','SimRFV2CWSourceType');
    schema.prop(this,'ZS','string');
    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'UseSqWave','bool');
    schema.prop(this,'NumCoeff','string');
    schema.prop(this,'Bias','string');
    schema.prop(this,'DutyCyc','string');
    schema.prop(this,'InternalGrounding','bool');

