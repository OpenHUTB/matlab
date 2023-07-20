function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'Visual');
    this=schema.class(rfPackage,'Xline',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};








    if isempty(findtype('SimRFV2EnumsDefineXline'))
        schema.EnumType('SimRFV2EnumsDefineXline',{'Yes'});

        schema.EnumType('SimRFV2XlineModelTypeEnum',{...
        'Delay-based and lossless','Delay-based and lossy',...
        'Lumped parameter L-section','Lumped parameter Pi-section'...
        ,'Coaxial','Coplanar waveguide','Microstrip','Stripline',...
        'Two-wire','Parallel-plate','Equation-based','RLCG'});

        schema.EnumType('SimRFV2XlineStructureTypeEnum',{...
        'Standard','Inverted','Suspended','Embedded'});

        mpars_lc=simrfV2_mask_combos('transmission_line_rf','LC_param');
        schema.EnumType('SimRFV2ParameterizeEnum',mpars_lc.Entries);

        schema.EnumType('SimRFV2OhmLengthUnit',{'Ohm/m','kOhm/m',...
        'MOhm/m','GOhm/m'});

        schema.EnumType('SimRFV2IndLengthUnit',{'H/m','mH/m',...
        'uH/m','nH/m'});

        schema.EnumType('SimRFV2CapLengthUnit',{'F/m','mF/m',...
        'uF/m','nF/m','pF/m'});

        schema.EnumType('SimRFV2SieLengthUnit',{'S/m','mS/m',...
        'uS/m','nS/m'});

        schema.EnumType('SimRFV2LengthUnit',{'m','cm','mm','um',...
        'in','ft'});

        schema.EnumType('StubModeOptions',{'Not a stub','Shunt','Series'});

        schema.EnumType('TerminationOptions',{'Open','Short'});

        schema.EnumType('SimRFV2XlineInterpType',{'Linear','Spline',...
        'Cubic'});
    end

    schema.prop(this,'Model_type','SimRFV2XlineModelTypeEnum');
    schema.prop(this,'StructureMicrostrip','SimRFV2XlineStructureTypeEnum');
    schema.prop(this,'Parameterization','SimRFV2ParameterizeEnum');
    schema.prop(this,'ConductorBacked','bool');

    schema.prop(this,'TransDelay','string');
    schema.prop(this,'TransDelay_unit','SimRFV2TimeUnitType');
    schema.prop(this,'CharImped','string');
    schema.prop(this,'CharImped_unit','SimRFV2ResistanceUnitType');
    schema.prop(this,'Resistance','string');
    schema.prop(this,'Resistance_unit','SimRFV2OhmLengthUnit');
    schema.prop(this,'Inductance','string');
    schema.prop(this,'Inductance_unit','SimRFV2IndLengthUnit');
    schema.prop(this,'Capacitance','string');
    schema.prop(this,'Capacitance_unit','SimRFV2CapLengthUnit');
    schema.prop(this,'Conductance','string');
    schema.prop(this,'Conductance_unit','SimRFV2SieLengthUnit');
    schema.prop(this,'LineLength','string');
    schema.prop(this,'LineLength_unit','SimRFV2LengthUnit');
    schema.prop(this,'NumSegments','string');

    schema.prop(this,'OuterRadius','string');
    schema.prop(this,'OuterRadius_unit','SimRFV2LengthUnit');
    schema.prop(this,'InnerRadius','string');
    schema.prop(this,'InnerRadius_unit','SimRFV2LengthUnit');
    schema.prop(this,'MuR','string');
    schema.prop(this,'EpsilonR','string');
    schema.prop(this,'LossTangent','string');
    schema.prop(this,'SigmaCond','string');
    schema.prop(this,'SigmaCond_unit','SimRFV2SieLengthUnit');
    schema.prop(this,'StubMode','StubModeOptions');
    schema.prop(this,'Termination','TerminationOptions');
    schema.prop(this,'ConductorWidth','string');
    schema.prop(this,'ConductorWidth_unit','SimRFV2LengthUnit');
    schema.prop(this,'SlotWidth','string');
    schema.prop(this,'SlotWidth_unit','SimRFV2LengthUnit');
    schema.prop(this,'Height','string');
    schema.prop(this,'Height_unit','SimRFV2LengthUnit');
    schema.prop(this,'Height_inv','string');
    schema.prop(this,'Height_inv_unit','SimRFV2LengthUnit');
    schema.prop(this,'Height_spd','string');
    schema.prop(this,'Height_spd_unit','SimRFV2LengthUnit');
    schema.prop(this,'Height_emb','string');
    schema.prop(this,'Height_emb_unit','SimRFV2LengthUnit');
    schema.prop(this,'StripHeight','string');
    schema.prop(this,'StripHeight_unit','SimRFV2LengthUnit');
    schema.prop(this,'Thickness','string');
    schema.prop(this,'Thickness_unit','SimRFV2LengthUnit');
    schema.prop(this,'SWidth','string');
    schema.prop(this,'SWidth_unit','SimRFV2LengthUnit');
    schema.prop(this,'Radius','string');
    schema.prop(this,'Radius_unit','SimRFV2LengthUnit');
    schema.prop(this,'Separation','string');
    schema.prop(this,'Separation_unit','SimRFV2LengthUnit');
    schema.prop(this,'PWidth','string');
    schema.prop(this,'PWidth_unit','SimRFV2LengthUnit');
    schema.prop(this,'PSeparation','string');
    schema.prop(this,'PSeparation_unit','SimRFV2LengthUnit');
    schema.prop(this,'PV','string');
    schema.prop(this,'Loss','string');
    schema.prop(this,'Freq','string');
    schema.prop(this,'Freq_unit','SimRFV2FreqUnitType');
    schema.prop(this,'Interp_type','SimRFV2XlineInterpType');
    schema.prop(this,'FitOpt','SimRFV2FitOptType');
    schema.prop(this,'FitTol','string');
    schema.prop(this,'MaxPoles','string');
    schema.prop(this,'SparamRepresentation','SimRFV2SparamRepresentationType');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'MagModeling','bool');

    schema.prop(this,'InternalGrounding','bool');

