function schema






    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'Solver',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};





    schema.prop(this,'AutoFreq','bool');
    schema.prop(this,'Tones','string');
    schema.prop(this,'Tones_unit','SimRFV2FreqUnitType');
    schema.prop(this,'Harmonics','string');
    schema.prop(this,'SolverType','SimRFV2SolverType');
    schema.prop(this,'StepSize','string');
    schema.prop(this,'StepSize_unit','SimRFV2TimeUnitType');
    schema.prop(this,'AddNoise','bool');
    schema.prop(this,'DefaultRNG','bool');
    schema.prop(this,'Seed','string');
    schema.prop(this,'Temperature','string');
    schema.prop(this,'Temperature_unit','SimRFV2TemperatureUnitType');
    schema.prop(this,'SolverDelFlag','string');
    schema.prop(this,'SamplesPerFrame','string');
    schema.prop(this,'NormalizeCarrierPower','bool');
    schema.prop(this,'EnableInterpFilter','bool');
    schema.prop(this,'RelTol','string');
    schema.prop(this,'AbsTol','string');
    schema.prop(this,'MaxIter','string');
    schema.prop(this,'ErrorEstimationType','SimRFV2NewtonErrorEstimationType');
    schema.prop(this,'SmallSignalApprox','bool');
    schema.prop(this,'AllSimFreqs','bool');
    schema.prop(this,'SimFreqs','string');
    schema.prop(this,'SimFreqs_unit','SimRFV2FreqUnitType');


    m=schema.method(this,'simrfV2restoresolverdefaults');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(this,'simrfV2populatefreqs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(this,'simrfV2closesolver');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


