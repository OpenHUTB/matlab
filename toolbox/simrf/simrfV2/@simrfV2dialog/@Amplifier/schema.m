function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'Visual');
    this=schema.class(rfPackage,'Amplifier',parent);


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
    schema.prop(this,'AmAmAmPmTable','string');
    schema.prop(this,'FitOpt','SimRFV2FitOptType');
    schema.prop(this,'FitTol','string');
    schema.prop(this,'MaxPoles','string');
    schema.prop(this,'Source_linear_gain','SimRFV2AmplifierLinearGainDerivedFrom');
    schema.prop(this,'linear_gain','string');
    schema.prop(this,'linear_gain_unit','SimRFV2PowerGainUnit');
    schema.prop(this,'Zin','string');
    schema.prop(this,'Zout','string');
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
    schema.prop(this,'InternalGrounding','bool');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'MagModeling','bool');
    schema.prop(this,'AddNoise','bool');
    schema.prop(this,'NoiseType','SimRFV2NoiseType');
    schema.prop(this,'NoiseDist','SimRFV2NoiseDistributionType');
    schema.prop(this,'NF','string');
    schema.prop(this,'MinNF','string');
    schema.prop(this,'Gopt','string');
    schema.prop(this,'RN','string');
    schema.prop(this,'CarrierFreq','string');
    schema.prop(this,'CarrierFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'NoiseAutoImpulseLength','bool');
    schema.prop(this,'NoiseImpulseLength','string');
    schema.prop(this,'NoiseImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'ConstS21NL','bool');
    schema.prop(this,'SetOpFreqAsMaxS21','bool');
    schema.prop(this,'OpFreq','string');
    schema.prop(this,'OpFreq_unit','SimRFV2FreqUnitType');
