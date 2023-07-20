function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'SineSource',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'SineSourceType','SimRFV2SourceType');

    schema.prop(this,'VO_I','string');
    schema.prop(this,'VO_I_unit','SimRFV2VoltageUnit');
    schema.prop(this,'VO_Q','string');
    schema.prop(this,'VO_Q_unit','SimRFV2VoltageUnit');

    schema.prop(this,'IO_I','string');
    schema.prop(this,'IO_I_unit','SimRFV2CurrentUnit');
    schema.prop(this,'IO_Q','string');
    schema.prop(this,'IO_Q_unit','SimRFV2CurrentUnit');

    schema.prop(this,'VA_I','string');
    schema.prop(this,'VA_I_unit','SimRFV2VoltageUnit');
    schema.prop(this,'VA_Q','string');
    schema.prop(this,'VA_Q_unit','SimRFV2VoltageUnit');

    schema.prop(this,'IA_I','string');
    schema.prop(this,'IA_I_unit','SimRFV2CurrentUnit');
    schema.prop(this,'IA_Q','string');
    schema.prop(this,'IA_Q_unit','SimRFV2CurrentUnit');

    schema.prop(this,'Fmod','string');
    schema.prop(this,'Fmod_unit','SimRFV2FreqUnitType');

    schema.prop(this,'TD','string');
    schema.prop(this,'TD_unit','SimRFV2TimeUnitType');

    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'InternalGrounding','bool');

