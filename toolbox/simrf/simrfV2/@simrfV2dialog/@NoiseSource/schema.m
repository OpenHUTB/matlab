function schema




    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'NoiseSource',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'SimulinkInputSignalType','SimRFV2SourceType');
    schema.prop(this,'NoiseType','SimRFV2NoiseDistributionType');
    schema.prop(this,'NoisePSD','string');
    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'InternalGrounding','bool');

