%#codegen

function[MiniBatchSize,SequenceLength,SequencePaddingValue,SequencePaddingDirection,ReturnCategorical]=parseInputsCodegenPredictRNN(varargin)




    coder.allowpcode('plain');
    parms=struct(...
    'MiniBatchSize',uint32(0),...
    'ExecutionEnvironment',uint32(0),...
    'Acceleration',uint32(0),...
    'SequenceLength',uint32(0),...
    'SequencePaddingValue',uint32(0),...
    'SequencePaddingDirection',uint32(0),...
    'ReturnCategorical',false...
    );

    popt=struct(...
    'CaseSensitivity',false...
    );

    optarg=coder.const(@coder.internal.parseParameterInputs,parms,coder.const(popt),varargin{:});


    ExecutionEnvironment=coder.internal.getParameterValue(optarg.ExecutionEnvironment,...
    '',varargin{:});

    if~coder.internal.isConst(ExecutionEnvironment)||~coder.const(@isempty,ExecutionEnvironment)
        coder.internal.compileWarning(eml_message(...
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','predict','ExecutionEnvironment'));
    end

    Acceleration=coder.internal.getParameterValue(optarg.Acceleration,...
    '',varargin{:});

    if~coder.internal.isConst(Acceleration)||~coder.const(@isempty,Acceleration)
        coder.internal.compileWarning(eml_message(...
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','predict','Acceleration'));
    end


    MiniBatchSize=iGetAndValidateMiniBatchSize(optarg,varargin{:});

    ReturnCategorical=iGetAndValidateReturnCategorical(optarg,varargin{:});

    SequenceLength=iGetAndValidateSequenceLength(optarg,varargin{:});

    SequencePaddingValue=iGetAndValidateSequencePaddingValue(optarg,varargin{:});

    SequencePaddingDirection=iGetAndValidateSequencePaddingDirection(optarg,varargin{:});
end






function MiniBatchSize=iGetAndValidateMiniBatchSize(optarg,varargin)
    coder.inline('always');

    defaultMiniBatchSize=128;
    MiniBatchSize=coder.internal.getParameterValue(optarg.MiniBatchSize,...
    defaultMiniBatchSize,varargin{:});


    coder.internal.assert(coder.internal.isConst(MiniBatchSize),...
    'dlcoder_spkg:cnncodegen:VariableMiniBatchSize',...
    'predict');


    coder.internal.assert(coder.const(isscalar(MiniBatchSize))&&...
    coder.const(MiniBatchSize>0)&&...
    coder.const(mod(MiniBatchSize,1)==0),...
    'dlcoder_spkg:cnncodegen:InvalidMiniBatchSize',...
    'predict');
end


function ReturnCategorical=iGetAndValidateReturnCategorical(optarg,varargin)
    coder.inline('always');

    defaultReturnCategoricalValue=false;
    ReturnCategorical=coder.internal.getParameterValue(...
    optarg.ReturnCategorical,...
    defaultReturnCategoricalValue,...
    varargin{:});


    coder.internal.assert(coder.internal.isConst(ReturnCategorical),...
    'dlcoder_spkg:cnncodegen:VariableReturnCategorical');


    coder.internal.assert(islogical(ReturnCategorical),...
    'dlcoder_spkg:cnncodegen:InvalidReturnCategoricalType');
end


function SequencePaddingValue=iGetAndValidateSequencePaddingValue(optarg,varargin)
    coder.inline('always');

    defaultSequencePaddingValue=0;
    SequencePaddingValue=coder.internal.getParameterValue(optarg.SequencePaddingValue,...
    defaultSequencePaddingValue,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequencePaddingValue),...
    'dlcoder_spkg:cnncodegen:VariableSequencePaddingValue',...
    'predict');
end


function SequenceLength=iGetAndValidateSequenceLength(optarg,varargin)
    coder.inline('always');

    defaultSequenceLength='longest';
    supportedSequenceLengths={'longest','shortest'};
    SequenceLength=coder.internal.getParameterValue(optarg.SequenceLength,...
    defaultSequenceLength,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequenceLength),...
    'dlcoder_spkg:cnncodegen:VariableSequenceLength',...
    'predict','method');



    coder.internal.assert(any(strcmp(SequenceLength,supportedSequenceLengths)),...
    'dlcoder_spkg:cnncodegen:InvalidSequenceLength',...
    'predict');
end


function SequencePaddingDirection=iGetAndValidateSequencePaddingDirection(optarg,varargin)
    coder.inline('always');

    defaultSequencePaddingDirection='right';
    supportedSequencePaddingDirections={'right','left'};
    SequencePaddingDirection=coder.internal.getParameterValue(optarg.SequencePaddingDirection,...
    defaultSequencePaddingDirection,varargin{:});


    coder.internal.assert(coder.internal.isConst(SequencePaddingDirection),...
    'dlcoder_spkg:cnncodegen:VariableSequencePaddingDirection',...
    'predict');


    coder.internal.assert(any(strcmp(SequencePaddingDirection,supportedSequencePaddingDirections)),...
    'dlcoder_spkg:cnncodegen:InvalidSequencePaddingDirection',...
    'predict');
end
