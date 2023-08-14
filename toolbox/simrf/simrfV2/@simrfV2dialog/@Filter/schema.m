function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'FiltVisual');
    this=schema.class(rfPackage,'Filter',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'simrfV2exportfilter');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};




    schema.prop(this,'DesignMethod','SimRFV2FilterMethod');
    schema.prop(this,'ResponseType','SimRFV2FilterType');
    schema.prop(this,'Implementation','SimRFV2FilterImplementation');
    schema.prop(this,'ImplementationIdeal','SimRFV2FilterImplementationIdeal');
    schema.prop(this,'ImplementationRational','SimRFV2FilterImplementationRational');
    schema.prop(this,'UseFilterOrder','bool');
    schema.prop(this,'FilterOrder','string');
    schema.prop(this,'PassFreq_lp','string');
    schema.prop(this,'PassFreq_lp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'PassFreq_hp','string');
    schema.prop(this,'PassFreq_hp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'PassFreq_bp','string');
    schema.prop(this,'PassFreq_bp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'PassFreq_bs','string');
    schema.prop(this,'PassFreq_bs_unit','SimRFV2FreqUnitType');
    schema.prop(this,'PassAtten','string');
    schema.prop(this,'StopFreq_lp','string');
    schema.prop(this,'StopFreq_lp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'StopFreq_hp','string');
    schema.prop(this,'StopFreq_hp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'StopFreq_bp','string');
    schema.prop(this,'StopFreq_bp_unit','SimRFV2FreqUnitType');
    schema.prop(this,'StopFreq_bs','string');
    schema.prop(this,'StopFreq_bs_unit','SimRFV2FreqUnitType');
    schema.prop(this,'StopAtten','string');
    schema.prop(this,'Rsrc','string');
    schema.prop(this,'Rload','string');
    schema.prop(this,'AutoImpulseLength','bool');
    schema.prop(this,'ImpulseLength','string');
    schema.prop(this,'ImpulseLength_unit','SimRFV2TimeUnitType');
    schema.prop(this,'InternalGrounding','bool');


