function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'LadderLC',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};





    schema.prop(this,'LadderType','SimRFV2LadderLCType');
    schema.prop(this,'Inductance_lpt','string');
    schema.prop(this,'Inductance_lpt_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_lpt','string');
    schema.prop(this,'Capacitance_lpt_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_hpp','string');
    schema.prop(this,'Inductance_hpp_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_hpp','string');
    schema.prop(this,'Capacitance_hpp_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_lpp','string');
    schema.prop(this,'Inductance_lpp_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_lpp','string');
    schema.prop(this,'Capacitance_lpp_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_hpt','string');
    schema.prop(this,'Inductance_hpt_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_hpt','string');
    schema.prop(this,'Capacitance_hpt_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_bpt','string');
    schema.prop(this,'Inductance_bpt_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_bpt','string');
    schema.prop(this,'Capacitance_bpt_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_bpp','string');
    schema.prop(this,'Inductance_bpp_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_bpp','string');
    schema.prop(this,'Capacitance_bpp_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_bst','string');
    schema.prop(this,'Inductance_bst_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_bst','string');
    schema.prop(this,'Capacitance_bst_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'Inductance_bsp','string');
    schema.prop(this,'Inductance_bsp_unit','SimRFV2InductanceUnitType');
    schema.prop(this,'Capacitance_bsp','string');
    schema.prop(this,'Capacitance_bsp_unit','SimRFV2CapacitanceUnitType');
    schema.prop(this,'InternalGrounding','bool');

