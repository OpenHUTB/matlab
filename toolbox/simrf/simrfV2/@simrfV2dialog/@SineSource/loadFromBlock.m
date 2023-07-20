function loadFromBlock(this)







    this.SineSourceType=this.Block.SineSourceType;

    this.VO_I=this.Block.VO_I;
    this.VO_I_unit=this.Block.VO_I_unit;
    this.VO_Q=this.Block.VO_Q;
    this.VO_Q_unit=this.Block.VO_Q_unit;

    this.IO_I=this.Block.IO_I;
    this.IO_I_unit=this.Block.IO_I_unit;
    this.IO_Q=this.Block.IO_Q;
    this.IO_Q_unit=this.Block.IO_Q_unit;

    this.VA_I=this.Block.VA_I;
    this.VA_I_unit=this.Block.VA_I_unit;
    this.VA_Q=this.Block.VA_Q;
    this.VA_Q_unit=this.Block.VA_Q_unit;

    this.IA_I=this.Block.IA_I;
    this.IA_I_unit=this.Block.IA_I_unit;
    this.IA_Q=this.Block.IA_Q;
    this.IA_Q_unit=this.Block.IA_Q_unit;

    this.Fmod=this.Block.Fmod;
    this.Fmod_unit=this.Block.Fmod_unit;

    this.TD=this.Block.TD;
    this.TD_unit=this.Block.TD_unit;



    this.CarrierFreq=this.Block.CarrierFreq;
    this.CarrierFreq_unit=this.Block.CarrierFreq_unit;

    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');

