function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'PhaseShifter',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    schema.prop(this,'PhaseShift','string');
    schema.prop(this,'PhaseShift_unit','SimRFV2PhaseUnitType');
    schema.prop(this,'InternalGrounding','bool');

