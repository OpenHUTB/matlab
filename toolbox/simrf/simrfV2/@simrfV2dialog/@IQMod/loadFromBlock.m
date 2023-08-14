function loadFromBlock(this)







    this.Source_linear_gain=this.Block.Source_linear_gain;
    this.linear_gain=this.Block.linear_gain;
    this.linear_gain_unit=this.Block.linear_gain_unit;
    this.Poly_Coeffs=this.Block.Poly_Coeffs;
    this.LOFreq=this.Block.LOFreq;
    this.LOFreq_unit=this.Block.LOFreq_unit;
    this.Zin=this.Block.Zin;
    this.Zout=this.Block.Zout;
    this.AddIRFilters=strcmpi(this.Block.AddIRFilters,'on');
    this.AddCSFilter=strcmpi(this.Block.AddCSFilter,'on');
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


    this.GainMismatch=this.Block.GainMismatch;
    this.GainMismatch_unit=this.Block.GainMismatch_unit;
    this.PhaseMismatch=this.Block.PhaseMismatch;
    this.PhaseMismatch_unit=this.Block.PhaseMismatch_unit;
    this.Isolation=this.Block.Isolation;
    this.Isolation_unit=this.Block.Isolation_unit;
    this.NFloor=this.Block.NFloor;
    this.AddPhaseNoise=strcmpi(this.Block.AddPhaseNoise,'on');
    this.PhaseNoiseOffset=this.Block.PhaseNoiseOffset;
    this.PhaseNoiseLevel=this.Block.PhaseNoiseLevel;
    this.AutoImpulseLengthPN=strcmpi(this.Block.AutoImpulseLengthPN,'on');
    this.ImpulseLengthPN=this.Block.ImpulseLengthPN;
    this.ImpulseLength_unitPN=this.Block.ImpulseLength_unitPN;


    this.Source_Poly=this.Block.Source_Poly;
    this.IPType=this.Block.IPType;
    this.IP2=this.Block.IP2;
    this.IP2_unit=this.Block.IP2_unit;
    this.IP3=this.Block.IP3;
    this.IP3_unit=this.Block.IP3_unit;
    this.P1dB=this.Block.P1dB;
    this.P1dB_unit=this.Block.P1dB_unit;
    this.Psat=this.Block.Psat;
    this.Psat_unit=this.Block.Psat_unit;
    this.Gcomp=this.Block.Gcomp;
    this.Gcomp_unit=this.Block.Gcomp_unit;


    tagEnds={'IR','CS'};
    for FilterInd=1:length(tagEnds)
        tagEnd=tagEnds{FilterInd};
        this.(['DesignMethod',tagEnd])=this.Block.(['DesignMethod',tagEnd]);
        this.(['ResponseType',tagEnd])=this.Block.(['ResponseType',tagEnd]);
        this.(['Implementation',tagEnd])=this.Block.(['Implementation',tagEnd]);
        this.(['ImplementationIdeal',tagEnd])=this.Block.(['ImplementationIdeal',tagEnd]);
        this.(['ImplementationRational',tagEnd])=this.Block.(['ImplementationRational',tagEnd]);
        this.(['UseFilterOrder',tagEnd])=strcmpi(this.Block.(['UseFilterOrder',tagEnd]),'on');
        this.(['FilterOrder',tagEnd])=this.Block.(['FilterOrder',tagEnd]);
        this.(['PassFreq_lp',tagEnd])=this.Block.(['PassFreq_lp',tagEnd]);
        this.(['PassFreq_lp_unit',tagEnd])=this.Block.(['PassFreq_lp_unit',tagEnd]);
        this.(['PassFreq_hp',tagEnd])=this.Block.(['PassFreq_hp',tagEnd]);
        this.(['PassFreq_hp_unit',tagEnd])=this.Block.(['PassFreq_hp_unit',tagEnd]);
        this.(['PassFreq_bp',tagEnd])=this.Block.(['PassFreq_bp',tagEnd]);
        this.(['PassFreq_bp_unit',tagEnd])=this.Block.(['PassFreq_bp_unit',tagEnd]);
        this.(['PassFreq_bs',tagEnd])=this.Block.(['PassFreq_bs',tagEnd]);
        this.(['PassFreq_bs_unit',tagEnd])=this.Block.(['PassFreq_bs_unit',tagEnd]);
        this.(['PassAtten',tagEnd])=this.Block.(['PassAtten',tagEnd]);
        this.(['StopFreq_lp',tagEnd])=this.Block.(['StopFreq_lp',tagEnd]);
        this.(['StopFreq_lp_unit',tagEnd])=this.Block.(['StopFreq_lp_unit',tagEnd]);
        this.(['StopFreq_hp',tagEnd])=this.Block.(['StopFreq_hp',tagEnd]);
        this.(['StopFreq_hp_unit',tagEnd])=this.Block.(['StopFreq_hp_unit',tagEnd]);
        this.(['StopFreq_bp',tagEnd])=this.Block.(['StopFreq_bp',tagEnd]);
        this.(['StopFreq_bp_unit',tagEnd])=this.Block.(['StopFreq_bp_unit',tagEnd]);
        this.(['StopFreq_bs',tagEnd])=this.Block.(['StopFreq_bs',tagEnd]);
        this.(['StopFreq_bs_unit',tagEnd])=this.Block.(['StopFreq_bs_unit',tagEnd]);
        this.(['StopAtten',tagEnd])=this.Block.(['StopAtten',tagEnd]);
        this.(['Rsrc',tagEnd])=this.Block.(['Rsrc',tagEnd]);
        this.(['Rload',tagEnd])=this.Block.(['Rload',tagEnd]);
        this.(['AutoImpulseLength',tagEnd])=strcmpi(this.Block.(['AutoImpulseLength',tagEnd]),'on');
        this.(['ImpulseLength',tagEnd])=this.Block.(['ImpulseLength',tagEnd]);
        this.(['ImpulseLength_unit',tagEnd])=this.Block.(['ImpulseLength_unit',tagEnd]);
    end


