function loadFromBlock(this)







    this.Source_linear_gain=this.Block.Source_linear_gain;
    this.linear_gain=this.Block.linear_gain;
    this.linear_gain_unit=this.Block.linear_gain_unit;
    this.Poly_Coeffs=this.Block.Poly_Coeffs;
    this.AmAmAmPmTable=this.Block.AmAmAmPmTable;
    this.DataSource=this.Block.DataSource;
    this.File=this.Block.File;
    this.Paramtype=this.Block.Paramtype;
    this.isNetworkObj=strcmpi(this.Block.isNetworkObj,'on');
    this.NetworkObject=this.Block.NetworkObject;
    this.Sparam=this.Block.Sparam;
    this.SparamFreq=this.Block.SparamFreq;
    this.SparamFreq_unit=this.Block.SparamFreq_unit;
    this.SparamZ0=this.Block.SparamZ0;
    this.isRationalObj=strcmpi(this.Block.isRationalObj,'on');
    this.RationalObject=this.Block.RationalObject;
    this.Residues=this.Block.Residues;
    this.Poles=this.Block.Poles;
    this.DF=this.Block.DF;
    this.Zin=this.Block.Zin;
    this.Zout=this.Block.Zout;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


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
    this.ConstS21NL=strcmpi(this.Block.ConstS21NL,'on');
    this.SetOpFreqAsMaxS21=strcmpi(this.Block.SetOpFreqAsMaxS21,'on');
    this.OpFreq=this.Block.OpFreq;
    this.OpFreq_unit=this.Block.OpFreq_unit;


    this.FitOpt=this.Block.FitOpt;
    this.FitTol=this.Block.FitTol;
    this.MaxPoles=this.Block.MaxPoles;
    this.SparamRepresentation=this.Block.SparamRepresentation;

    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;
    this.MagModeling=strcmpi(this.Block.MagModeling,'on');


    this.AddNoise=strcmpi(this.Block.AddNoise,'on');
    this.NoiseType=this.Block.NoiseType;
    this.NoiseDist=this.Block.NoiseDist;
    this.NF=this.Block.NF;
    this.MinNF=this.Block.MinNF;
    this.Gopt=this.Block.Gopt;
    this.RN=this.Block.RN;
    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;
    this.NoiseAutoImpulseLength=strcmpi(this.Block.NoiseAutoImpulseLength,'on');
    this.NoiseImpulseLength=this.Block.NoiseImpulseLength;
    this.NoiseImpulseLength_unit=this.Block.NoiseImpulseLength_unit;

