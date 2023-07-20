function cfg=validateArgs(varargin)






    if nargin==1&&isa(varargin{1},'coder.gpuEnvConfig')
        cfg=varargin{1};
        return;
    end

    pObj=inputParser;
    pObj.PartialMatching=false;


    xcompile={'tk1','tx1','tx2','crosscompile'};
    options={'quiet','default','host','full','gpu',...
    'codegen','codeexec','cudnn','tensorrt','tensorrtint8','profiling'};
    for i=1:numel(options)
        optionName=['OPTION',num2str(i)];
        addOptional(pObj,optionName,'',...
        @(x)customValidateString(x,options,xcompile));
    end


    targets={'mex','dll','lib','exe'};
    addParameter(pObj,'target','mex',...
    @(x)customValidateTarget(x,targets));

    parse(pObj,varargin{:});


    checkParams=struct();
    for i=1:numel(options)
        checkParams.(options{i})=false;
    end




    hasCheckOption=false;
    for i=1:numel(options)
        optionName=['OPTION',num2str(i)];
        option=lower(pObj.Results.(optionName));
        if~isempty(pObj.Results.(optionName))
            checkParams.(option)=true;
            if~strcmpi(option,'quiet')
                hasCheckOption=true;
            end
        end
    end

    if~hasCheckOption
        checkParams.default=true;
    end

    if strcmp(pObj.Results.target,'mex')
        tensorRTCodegen=true;
    else
        tensorRTCodegen=false;
    end
    cfg=coder.gpuEnvConfig('host');



    fieldNames=fieldnames(checkParams);
    for i=1:numel(fieldNames)
        fieldName=fieldNames{i};
        if islogical(checkParams.(fieldName))&&checkParams.(fieldName)
            switch fieldName
            case 'host'
            case 'gpu'

            case 'default'
                cfg.BasicCodeexec=true;
                cfg.DeepLibTarget='cudnn';
            case 'full'
                cfg.BasicCodeexec=true;
                cfg.DeepLibTarget='tensorrt';
                cfg.DeepCodeexec=true;
                cfg.DataType='int8';
                cfg.Profiling=true;
            case 'codegen'
                cfg.BasicCodegen=true;
            case 'codeexec'
                cfg.BasicCodeexec=true;
            case 'cudnn'
                cfg.DeepLibTarget='cudnn';
            case 'tensorrt'
                cfg.DeepLibTarget='tensorrt';
                if tensorRTCodegen
                    cfg.DeepCodeexec=true;
                end
            case 'tensorrtint8'
                cfg.DeepLibTarget='tensorrt';
                cfg.DataType='int8';
                cfg.DeepCodeexec=true;
            case 'profiling'
                cfg.Profiling=true;
            case 'quiet'
                cfg.Quiet=true;
            otherwise
            end
        end
    end

end

function x=customValidateString(x,options,xcompile)

    try
        x=any(validatestring(x,options));
    catch e
        if any(strcmpi(x,xcompile))
            error(message('gpucoder:system:gpu_check_crosscompile',x));
        else
            error(message('gpucoder:system:gpu_check_config',e.message));
        end
    end
end

function x=customValidateTarget(x,targets)
    try
        x=any(validatestring(x,targets,'coder.checkGpuInstall','target'));
    catch e
        error(message('gpucoder:system:gpu_check_config',e.message));
    end
end
