function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'Mixer',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'Source_linear_gain','SimRFV2MixerLinearGainDerivedFrom');
    schema.prop(this,'linear_gain','string');
    schema.prop(this,'linear_gain_unit','SimRFV2PowerGainUnit');
    schema.prop(this,'Zin','string');
    schema.prop(this,'Zout','string');
    schema.prop(this,'ZLO','string');
    schema.prop(this,'Source_Poly','SimRFV2PolyDerivedFrom');
    schema.prop(this,'Poly_Coeffs','string');
    schema.prop(this,'IPType','SimRFV2NonlinearDataMeasuredAt');
    schema.prop(this,'IP2','string');
    schema.prop(this,'IP2_unit','SimRFV2PowerUnit');
    schema.prop(this,'IP3','string');
    schema.prop(this,'IP3_unit','SimRFV2PowerUnit');
    schema.prop(this,'P1dB','string');
    schema.prop(this,'P1dB_unit','SimRFV2PowerUnit');
    schema.prop(this,'Psat','string');
    schema.prop(this,'Psat_unit','SimRFV2PowerUnit');
    schema.prop(this,'Gcomp','string');
    schema.prop(this,'Gcomp_unit','SimRFV2PowerUnit');
    schema.prop(this,'NF','string');

    schema.prop(this,'InternalGrounding','bool');

