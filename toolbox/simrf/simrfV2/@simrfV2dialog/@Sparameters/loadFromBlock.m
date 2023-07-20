function loadFromBlock(this)







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
    this.AddNoise=strcmpi(this.Block.AddNoise,'on');
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


    this.FitOpt=this.Block.FitOpt;
    this.FitTol=this.Block.FitTol;
    this.MaxPoles=this.Block.MaxPoles;
    this.SparamRepresentation=this.Block.SparamRepresentation;

    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;
    this.MagModeling=strcmpi(this.Block.MagModeling,'on');

