%#codegen

function[MiniBatchSize,SequenceLength,SequencePaddingValue,SequencePaddingDirection]=parseInputsCodegenActivationsRNN(varargin)




    coder.allowpcode('plain');
    parms=struct(...
    'OutputAs',uint32(0),...
    'MiniBatchSize',uint32(0),...
    'ExecutionEnvironment',uint32(0),...
    'Acceleration',uint32(0),...
    'SequenceLength',uint32(0),...
    'SequencePaddingValue',uint32(0),...
    'SequencePaddingDirection',uint32(0)...
    );

    popt=struct(...
    'CaseSensitivity',false...
    );

    optarg=coder.const(@coder.internal.parseParameterInputs,parms,coder.const(popt),varargin{:});


    ExecutionEnvironment=coder.internal.getParameterValue(optarg.ExecutionEnvironment,...
    '',varargin{:});

    if~coder.internal.isConst(ExecutionEnvironment)||~coder.const(@isempty,ExecutionEnvironment)
        coder.internal.compileWarning(eml_message(...
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','activations','ExecutionEnvironment'));
    end

    Acceleration=coder.internal.getParameterValue(optarg.Acceleration,...
    '',varargin{:});

    if~coder.internal.isConst(Acceleration)||~coder.const(@isempty,Acceleration)
        coder.internal.compileWarning(eml_message(...
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','activations','Acceleration'));
    end


    iGetAndValidateOutputAs(optarg,varargin{:});

    MiniBatchSize=iGetAndValidateMiniBatchSize(optarg,varargin{:});

    SequenceLength=iGetAndValidateSequenceLength(optarg,varargin{:});

    SequencePaddingValue=iGetAndValidateSequencePaddingValue(optarg,varargin{:});

    SequencePaddingDirection=iGetAndValidateSequencePaddingDirection(optarg,varargin{:});
end





function iGetAndValidateOutputAs(optarg,varargin)
    coder.inline('always');

    OutputAs=coder.internal.getParameterValue(optarg.OutputAs,...
    'channels',varargin{:});

    coder.internal.assert(coder.internal.isConst(OutputAs)&&...
    coder.const(@strcmpi,OutputAs,'channels'),...
    'dlcoder_spkg:cnncodegen:invalid_outputAsOption');
end


function MiniBatchSize=iGetAndValidateMiniBatchSize(optarg,varargin)
    coder.inline('always');

    defaultMiniBatchSize=128;
    MiniBatchSize=coder.internal.getParameterValue(optarg.MiniBatchSize,...
    defaultMiniBatchSize,varargin{:});


    coder.internal.assert(coder.internal.isConst(MiniBatchSize),...
    'dlcoder_spkg:cnncodegen:VariableMiniBatchSize',...
    'activations');


    coder.internal.assert(coder.const(isscalar(MiniBatchSize))&&...
    coder.const(MiniBatchSize>0)&&...
    coder.const(mod(MiniBatchSize,1)==0),...
    'dlcoder_spkg:cnncodegen:InvalidMiniBatchSize',...
    'activations');
end


function SequencePaddingValue=iGetAndValidateSequencePaddingValue(optarg,varargin)
    coder.inline('always');

    defaultSequencePaddingValue=0;
    SequencePaddingValue=coder.internal.getParameterValue(optarg.SequencePaddingValue,...
    defaultSequencePaddingValue,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequencePaddingValue),...
    'dlcoder_spkg:cnncodegen:VariableSequencePaddingValue',...
    'activations');
end


function SequenceLength=iGetAndValidateSequenceLength(optarg,varargin)
    coder.inline('always');

    defaultSequenceLength='longest';
    supportedSequenceLengths={'longest','shortest'};
    SequenceLength=coder.internal.getParameterValue(optarg.SequenceLength,...
    defaultSequenceLength,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequenceLength),...
    'dlcoder_spkg:cnncodegen:VariableSequenceLength',...
    'activations','method');



    coder.internal.assert(any(strcmp(SequenceLength,supportedSequenceLengths)),...
    'dlcoder_spkg:cnncodegen:InvalidSequenceLength',...
    'activations');
end


function SequencePaddingDirection=iGetAndValidateSequencePaddingDirection(optarg,varargin)
    coder.inline('always');

    defaultSequencePaddingDirection='right';
    supportedSequencePaddingDirections={'right','left'};
    SequencePaddingDirection=coder.internal.getParameterValue(optarg.SequencePaddingDirection,...
    defaultSequencePaddingDirection,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequencePaddingDirection),...
    'dlcoder_spkg:cnncodegen:VariableSequencePaddingDirection',...
    'activations');


    coder.internal.assert(any(strcmp(SequencePaddingDirection,supportedSequencePaddingDirections)),...
    'dlcoder_spkg:cnncodegen:InvalidSequencePaddingDirection',...
    'activations');
end
