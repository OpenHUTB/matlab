

function Name=BlocktypeToName(blocktype)

    switch lower(blocktype)
    case 'inport'
        Name='Inport';
    case 'inportshadow'
        Name='Inport Shadow';
    case 'enableport'
        Name='Enable Port';
    case 'triggerport'
        Name='Trigger Port';
    case 'constant'
        Name='Constant';
    case 'buscreator'
        Name='Bus Creator';
    case 'busselector'
        Name='Bus Selector';
    case 'busassignment'
        Name='Bus Assignment';
    case 'datastorememory'
        Name='Data Store Memory';
    case 'datastoreread'
        Name='Data Store Read';
    case 'datastorewrite'
        Name='Data Store Write';
    case 'fcn'
        Name='Fcn';
    case 'from'
        Name='From';
    case 'goto'
        Name='Goto';
    case 'switch'
        Name='Switch';
    case 'multiportswitch'
        Name='Multiport Switch';
    case 'mux'
        Name='Mux';
    case 'demux'
        Name='Demux';
    case 'selector'
        Name='Selector';
    case 'datatypeconversion'
        Name='Data Type Conversion';
    case 'datatypeduplicate'
        Name='Data Type Duplicate';
    case 'datatypepropagation'
        Name='Data Type Propagation';
    case 'signalspecification'
        Name='Signal Specification';
    case 'signalconversion'
        Name='Signal Conversion';
    case 'unitconversion'
        Name='Unit Conversion';
    case 'abs'
        Name='Absolute';
    case 'bias'
        Name='Bias';
    case 'ground'
        Name='Ground';
    case 'sqrt'
        Name='Sqrt';
    case 'gain'
        Name='Gain';
    case 'initialcondition'
        Name='Initial Condition';
    case 'math'
        Name='Math';
    case 'product'
        Name='Product';
    case 'sum'
        Name='Sum';
    case 'trigonometry'
        Name='Trigonometry';
    case 'minmax'
        Name='Minmax';
    case 'relationaloperator'
        Name='Relational Operator';
    case 'logic'
        Name='Logic';
    case 'combinatoriallogic'
        Name='Combinatorial Logic';
    case 'merge'
        Name='Merge';
    case 'lookup_n-d'
        Name='Lookup Table (n-D)';
    case 'prelookup'
        Name='PreLookup';
    case 'interpolation_n-d'
        Name='Interpolation Using Prelookup (n-D)';
    case 's-function'
        Name='S-Function';
    case 'modelreference'
        Name='Model Reference';
    case 'subsystem'
        Name='Subsystem';
    case 'display'
        Name='Display';
    case 'outport'
        Name='Outport';
    case 'scope'
        Name='Scope';
    case 'stateflow'
        Name='Stateflow';
    case 'terminator'
        Name='Terminator';
    case 'unitdelay'
        Name='Unit Delay';
    case 'discreteintegrator'
        Name='Discrete Integrator';
    case 'saturate'
        Name='Saturate';
    case 'deadzone'
        Name='Dead Zone';
    case 'delay'
        Name='Delay';
    case 'rounding'
        Name='Rounding Function';
    case 'actionport'
        Name='Action Port';
    case 'if'
        Name='If';
    case 'switchcase'
        Name='SwitchCase';
    case 'bitwise_operator'
        Name='Bitwise Operator';
    case{'fcncallgen','fcgen'}
        Name='Function-Call Generator';
    case 'arithshift'
        Name='ArithShift';
    case 'reshape'
        Name='Reshape';
    case 'probe'
        Name='Probe';
    case 'width'
        Name='Width';
    case 'signum'
        Name='Sign';
    case 'concatenate'
        Name='Vector Concatenate';
    case 'actionsubsystem'
        Name='Action Subsystem';
    case 'assignment'
        Name='Assignment';
    case 'polyval'
        Name='Polynomial';
    case 'dotproduct'
        Name='DotProduct';
    case 'unaryminus'
        Name='UnaryMinus';
    case 'matlabfunction'
        Name='Matlab Function';
    case 'ratetransition'
        Name='RateTransition';
    case 'relay'
        Name='Relay';
    case 'foriterator'
        Name='For Iterator';
    case 'foreach'
        Name='For Each';
    case 'statecontrol'
        Name='State Control';
    case 'asciitostring'
        Name='ASCIIToString';
    case 'functioncallsplit'
        Name='Function-Call Split';
    case 'whileiterator'
        Name='While Iterator';
    case 'ccaller'
        Name='C Caller';
    case 'functioncaller'
        Name='Function Caller';
    case 'simulinkfunction'
        Name='Simulink Function';
    otherwise
        assert(false,['*** Add this block type ',blocktype,' to ',mfilename('fullpath'),'***']);
    end





