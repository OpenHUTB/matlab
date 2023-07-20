%#codegen

function Outputs=parseInputsCodegenPredict(varargin)




    coder.allowpcode('plain');
    parms=struct(...
    'Outputs','',...
    'Acceleration','');

    popt=struct(...
    'CaseSensitivity',false...
    );

    optarg=coder.const(@coder.internal.parseParameterInputs,parms,coder.const(popt),varargin{:});


    Outputs=coder.internal.getParameterValue(optarg.Outputs,...
    '',varargin{:});


    Acceleration=coder.internal.getParameterValue(optarg.Acceleration,...
    '',varargin{:});

    if~coder.internal.isConst(Acceleration)||~coder.const(@isempty,Acceleration)
        coder.internal.compileWarning(eml_message(...
        'dlcoder_spkg:cnncodegen:IgnoreInputArg','predict','Acceleration'));
    end


    iValidateOutputs(Outputs);

end

function iValidateOutputs(Outputs)

    coder.internal.assert(coder.internal.isConst(Outputs),...
    'dlcoder_spkg:dlnetwork:NonConstantLayerNames','predict');

    isString=coder.const(isstring(Outputs));
    isCellStr=coder.const(iscellstr(Outputs));
    isChar=coder.const(coder.internal.isCharOrScalarString(Outputs));

    coder.internal.assert(isChar||isCellStr||isString,...
    'dlcoder_spkg:dlnetwork:UnsupportedOutputsValue','predict');


end


