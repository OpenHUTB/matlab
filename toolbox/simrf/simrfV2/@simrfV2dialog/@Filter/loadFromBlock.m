function loadFromBlock(this)







    this.DesignMethod=this.Block.DesignMethod;
    this.ResponseType=this.Block.ResponseType;
    this.Implementation=this.Block.Implementation;
    this.ImplementationIdeal=this.Block.ImplementationIdeal;
    this.ImplementationRational=this.Block.ImplementationRational;
    this.UseFilterOrder=strcmpi(this.Block.UseFilterOrder,'on');
    this.FilterOrder=this.Block.FilterOrder;
    this.PassFreq_lp=this.Block.PassFreq_lp;
    this.PassFreq_lp_unit=this.Block.PassFreq_lp_unit;
    this.PassFreq_hp=this.Block.PassFreq_hp;
    this.PassFreq_hp_unit=this.Block.PassFreq_hp_unit;
    this.PassFreq_bp=this.Block.PassFreq_bp;
    this.PassFreq_bp_unit=this.Block.PassFreq_bp_unit;
    this.PassFreq_bs=this.Block.PassFreq_bs;
    this.PassFreq_bs_unit=this.Block.PassFreq_bs_unit;
    this.PassAtten=this.Block.PassAtten;
    this.StopFreq_lp=this.Block.StopFreq_lp;
    this.StopFreq_lp_unit=this.Block.StopFreq_lp_unit;
    this.StopFreq_hp=this.Block.StopFreq_hp;
    this.StopFreq_hp_unit=this.Block.StopFreq_hp_unit;
    this.StopFreq_bp=this.Block.StopFreq_bp;
    this.StopFreq_bp_unit=this.Block.StopFreq_bp_unit;
    this.StopFreq_bs=this.Block.StopFreq_bs;
    this.StopFreq_bs_unit=this.Block.StopFreq_bs_unit;
    this.StopAtten=this.Block.StopAtten;
    this.Rsrc=this.Block.Rsrc;
    this.Rload=this.Block.Rload;
    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


