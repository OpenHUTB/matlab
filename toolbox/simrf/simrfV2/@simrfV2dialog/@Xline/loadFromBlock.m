function loadFromBlock(this)







    this.Model_type=this.Block.Model_type;
    this.StructureMicrostrip=this.Block.StructureMicrostrip;
    this.Parameterization=this.Block.Parameterization;
    this.ConductorBacked=strcmpi(this.Block.ConductorBacked,'on');

    this.TransDelay=this.Block.TransDelay;
    this.TransDelay_unit=this.Block.TransDelay_unit;
    this.CharImped=this.Block.CharImped;
    this.CharImped_unit=this.Block.CharImped_unit;
    this.Resistance=this.Block.Resistance;
    this.Resistance_unit=this.Block.Resistance_unit;
    this.Inductance=this.Block.Inductance;
    this.Inductance_unit=this.Block.Inductance_unit;
    this.Capacitance=this.Block.Capacitance;
    this.Capacitance_unit=this.Block.Capacitance_unit;
    this.Conductance=this.Block.Conductance;
    this.Conductance_unit=this.Block.Conductance_unit;
    this.LineLength=this.Block.LineLength;
    this.LineLength_unit=this.Block.LineLength_unit;
    this.NumSegments=this.Block.NumSegments;

    this.OuterRadius=this.Block.OuterRadius;
    this.OuterRadius_unit=this.Block.OuterRadius_unit;
    this.InnerRadius=this.Block.InnerRadius;
    this.InnerRadius_unit=this.Block.InnerRadius_unit;
    this.MuR=this.Block.MuR;
    this.EpsilonR=this.Block.EpsilonR;
    this.LossTangent=this.Block.LossTangent;
    this.SigmaCond=this.Block.SigmaCond;
    this.SigmaCond_unit=this.Block.SigmaCond_unit;
    this.StubMode=this.Block.StubMode;
    this.Termination=this.Block.Termination;
    this.ConductorWidth=this.Block.ConductorWidth;
    this.ConductorWidth_unit=this.Block.ConductorWidth_unit;
    this.SlotWidth=this.Block.SlotWidth;
    this.SlotWidth_unit=this.Block.SlotWidth_unit;
    this.Height=this.Block.Height;
    this.Height_unit=this.Block.Height_unit;
    this.Height_inv=this.Block.Height_inv;
    this.Height_inv_unit=this.Block.Height_inv_unit;
    this.Height_spd=this.Block.Height_spd;
    this.Height_spd_unit=this.Block.Height_spd_unit;
    this.Height_emb=this.Block.Height_emb;
    this.Height_emb_unit=this.Block.Height_emb_unit;
    this.StripHeight=this.Block.StripHeight;
    this.StripHeight_unit=this.Block.StripHeight_unit;
    this.Thickness=this.Block.Thickness;
    this.Thickness_unit=this.Block.Thickness_unit;
    this.SWidth=this.Block.SWidth;
    this.SWidth_unit=this.Block.SWidth_unit;
    this.Radius=this.Block.Radius;
    this.Radius_unit=this.Block.Radius_unit;
    this.Separation=this.Block.Separation;
    this.Separation_unit=this.Block.Separation_unit;
    this.PWidth=this.Block.PWidth;
    this.PWidth_unit=this.Block.PWidth_unit;
    this.PSeparation=this.Block.PSeparation;
    this.PSeparation_unit=this.Block.PSeparation_unit;
    this.PV=this.Block.PV;
    this.Loss=this.Block.Loss;
    this.Freq=this.Block.Freq;
    this.Freq_unit=this.Block.Freq_unit;
    this.Interp_type=this.Block.Interp_type;

    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


    this.FitOpt=this.Block.FitOpt;
    this.FitTol=this.Block.FitTol;
    this.MaxPoles=this.Block.MaxPoles;
    this.SparamRepresentation=this.Block.SparamRepresentation;

    this.AutoImpulseLength=strcmpi(this.Block.AutoImpulseLength,'on');
    this.ImpulseLength=this.Block.ImpulseLength;
    this.ImpulseLength_unit=this.Block.ImpulseLength_unit;
    this.MagModeling=strcmpi(this.Block.MagModeling,'on');

