function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'GatewayOut',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'SensorType','SimRFV2CWSourceType');
    schema.prop(this,'ZL','string');
    schema.prop(this,'OutputFormat','SimRFV2GatewayOutputFormat');
    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'InternalGrounding','bool');
    schema.prop(this,'StepSize','string');
    schema.prop(this,'StepSize_unit','SimRFV2TimeUnitType');
    schema.prop(this,'AutoStep','bool');

