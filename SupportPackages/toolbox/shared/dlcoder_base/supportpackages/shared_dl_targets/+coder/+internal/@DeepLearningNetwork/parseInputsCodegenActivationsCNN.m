%#codegen

function[MiniBatchSize]=parseInputsCodegenActivationsCNN(varargin)




    coder.allowpcode('plain');
    parms=struct(...
    'OutputAs',uint32(0),...
    'MiniBatchSize',uint32(0),...
    'ExecutionEnvironment',uint32(0),...
    'Acceleration',uint32(0)...
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
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','predict','Acceleration'));
    end


    iGetAndValidateOutputAs(optarg,varargin{:});

    MiniBatchSize=iGetAndValidateMiniBatchSize(optarg,varargin{:});
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
