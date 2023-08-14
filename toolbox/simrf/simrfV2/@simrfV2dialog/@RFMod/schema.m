function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'RFMod',parent);


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
    schema.prop(this,'LOFreq','string');
    schema.prop(this,'LOFreq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'Isolation','string');
    schema.prop(this,'Isolation_unit','SimRFV2PowerGainUnit');
    schema.prop(this,'NF','string');
    schema.prop(this,'AddPhaseNoise','bool');
    schema.prop(this,'PhaseNoiseOffset','string');
    schema.prop(this,'PhaseNoiseLevel','string');
    schema.prop(this,'AutoImpulseLengthPN','bool');
    schema.prop(this,'ImpulseLengthPN','string');
    schema.prop(this,'ImpulseLength_unitPN','SimRFV2TimeUnitType');
    schema.prop(this,'AddIRFilter','bool');
    schema.prop(this,'AddCSFilter','bool');

    schema.prop(this,'InternalGrounding','bool');

    tagEnds={'IR','CS'};
    for FilterInd=1:length(tagEnds)
        tagEnd=tagEnds{FilterInd};
        schema.prop(this,['DesignMethod',tagEnd],'SimRFV2FilterMethod');
        schema.prop(this,['ResponseType',tagEnd],'SimRFV2FilterType');
        schema.prop(this,['Implementation',tagEnd],'SimRFV2FilterImplementation');
        schema.prop(this,['ImplementationIdeal',tagEnd],'SimRFV2FilterImplementationIdeal');
        schema.prop(this,['ImplementationRational',tagEnd],'SimRFV2FilterImplementationRational');
        schema.prop(this,['UseFilterOrder',tagEnd],'bool');
        schema.prop(this,['FilterOrder',tagEnd],'string');
        schema.prop(this,['PassFreq_lp',tagEnd],'string');
        schema.prop(this,['PassFreq_lp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['PassFreq_hp',tagEnd],'string');
        schema.prop(this,['PassFreq_hp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['PassFreq_bp',tagEnd],'string');
        schema.prop(this,['PassFreq_bp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['PassFreq_bs',tagEnd],'string');
        schema.prop(this,['PassFreq_bs_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['PassAtten',tagEnd],'string');
        schema.prop(this,['StopFreq_lp',tagEnd],'string');
        schema.prop(this,['StopFreq_lp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['StopFreq_hp',tagEnd],'string');
        schema.prop(this,['StopFreq_hp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['StopFreq_bp',tagEnd],'string');
        schema.prop(this,['StopFreq_bp_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['StopFreq_bs',tagEnd],'string');
        schema.prop(this,['StopFreq_bs_unit',tagEnd],'SimRFV2FreqUnitType');
        schema.prop(this,['StopAtten',tagEnd],'string');
        schema.prop(this,['Rsrc',tagEnd],'string');
        schema.prop(this,['Rload',tagEnd],'string');
        schema.prop(this,['AutoImpulseLength',tagEnd],'bool');
        schema.prop(this,['ImpulseLength',tagEnd],'string');
        schema.prop(this,['ImpulseLength_unit',tagEnd],'SimRFV2TimeUnitType');
    end

