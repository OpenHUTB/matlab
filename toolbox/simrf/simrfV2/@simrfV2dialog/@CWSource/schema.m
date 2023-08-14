function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'CWSource',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'CWSourceType','SimRFV2CWSourceType');
    schema.prop(this,'Z0','string');
    schema.prop(this,'IVoltage','string');
    schema.prop(this,'ICurrent','string');
    schema.prop(this,'MagPower','string');
    schema.prop(this,'IVoltage_unit','SimRFV2VoltageUnit');
    schema.prop(this,'ICurrent_unit','SimRFV2CurrentUnit');
    schema.prop(this,'MagPower_unit','SimRFV2PowerUnit');
    schema.prop(this,'QVoltage','string');
    schema.prop(this,'QCurrent','string');
    schema.prop(this,'AnglePower','string');
    schema.prop(this,'QVoltage_unit','SimRFV2VoltageUnit');
    schema.prop(this,'QCurrent_unit','SimRFV2CurrentUnit');

    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');

    schema.prop(this,'AddPhaseNoise','bool');
    schema.prop(this,'PhaseNoiseOffset','string');
    schema.prop(this,'PhaseNoiseLevel','string');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');

    schema.prop(this,'InternalGrounding','bool');

