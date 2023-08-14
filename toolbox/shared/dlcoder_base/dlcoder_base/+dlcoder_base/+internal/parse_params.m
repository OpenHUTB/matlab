



function dlcodeConfig=parse_params(params)

    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.KeepUnmatched=true;
    pObj.PartialMatching=false;

    defaultTargetLib="arm-compute-mali";

    addParameter(pObj,'targetlib',defaultTargetLib,@(x)dlcoder_base.internal.checkSupportedTargetLibForCnnCodegen(x));
    addParameter(pObj,'batchsize',1,@(x)validateattributes(x,{'numeric'},{'scalar','>',0,'integer'}));
    addParameter(pObj,'targetdir',fullfile(pwd,'codegen'),@(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(pObj,'targetfile','cnn_exec.cpp',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(pObj,'opencv',0,@(x)checkVal(x,[0,1],'0,1'));
    addParameter(pObj,'codetarget','rtw:lib',@(x)checkVal(x,{'rtw:lib','rtw:dll','rtw:exe'},'''rtw:lib'', ''rtw:dll'' and ''rtw:exe'''));
    addParameter(pObj,'targetmain','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(pObj,'codegenonly',0,@(x)checkVal(x,[0,1],'0,1'));
    addParameter(pObj,'computecapability',coder.GpuCodeConfig.DefaultComputeCapability,@(x)(ischar(x)||isstring(x)));
    addParameter(pObj,'targetparams',struct(),@(x)validateattributes(x,{'struct'},{}));
    addParameter(pObj,'optimizationflags',struct(),@(x)validateattributes(x,{'struct'},{}));
    addParameter(pObj,'debugmode',false,@(x)validateattributes(x,{'logical'},{}));

    params=convertStringParamsToChar(params);
    parse(pObj,params{:});
    pvpairs=pObj.Results;

    pvpairs=convertToLower(pvpairs);

    dlcoder_base.internal.checkForSupportPackages(pvpairs.targetlib);


    unmatchedParams=fields(pObj.Unmatched);
    for k=1:numel(unmatchedParams)
        error(message('gpucoder:cnncodegen:unsupported_parameter_name',unmatchedParams{k},'any'));
    end


    if((~isempty(pvpairs.targetmain))&&(~exist(pvpairs.targetmain,'file')))
        warning(message('gpucoder:cnncodegen:invalid_main_file',pvpairs.targetmain));
        pvpairs.targetmain='';
    end


    targetlib=lower(pvpairs.targetlib);

    pvpairs=checkArmParams(pvpairs,targetlib,pObj.UsingDefaults);
    dlcodeConfig=populateConfigFromParams(pvpairs);
    dlcodeConfig.validateAndSetBuildConfig;

end

function params=convertStringParamsToChar(params)
    for i=1:numel(params)
        if isstruct(params{i})
            paramFields=fieldnames(params{i});
            for id=1:numel(paramFields)
                params{i}.(paramFields{id})=convertStringsToChars(params{i}.(paramFields{id}));
            end

        else
            params{i}=convertStringsToChars(params{i});
        end
    end
end




function pvpairs=checkArmParams(pvpairs,targetname,defaults)
    pvpairs=dlcoder_base.internal.ArmParamsValidation(pvpairs,targetname);


    unsupportedParameters={'computecapability'};
    checkUnsupportedParams(unsupportedParameters,pvpairs,defaults,targetname);
end

function checkVal(value,supportedValues,supportedValuesStr)
    value=convertStringsToChars(value);
    flag=ismember(value,supportedValues);
    if~flag&&~isempty(supportedValuesStr)
        error(message('gpucoder:cnncodegen:supported_values',supportedValuesStr));
    end
end

function checkUnsupportedParams(unsupportedParameters,pvpairs,defaults,targetname)
    for k=1:numel(unsupportedParameters)
        paramName=unsupportedParameters{k};
        if isfield(pvpairs,paramName)&&~ismember(paramName,defaults)
            error(message('gpucoder:cnncodegen:unsupported_parameter_name',paramName,targetname));
        end
    end
end

function pvpairs=convertToLower(pvpairs)
    pvpairs.targetlib=lower(pvpairs.targetlib);
end




function dlcodeConfig=populateConfigFromParams(pvpairs)






    dlcodeConfig=coder.internal.dlcodegenConfig(erase(pvpairs.codetarget,'rtw:'),pvpairs.targetlib);

    optimizations=fields(pvpairs.optimizationflags);
    for i=1:numel(optimizations)
        fieldName=optimizations{i};
        if~isempty(pvpairs.optimizationflags.(fieldName))
            dlcodeConfig.DeepLearningConfig.OptimizationConfig.(fieldName)=pvpairs.optimizationflags.(fieldName);
        end
    end


    dlcodeConfig.BatchSize=pvpairs.batchsize;
    dlcodeConfig.GenCodeOnly=pvpairs.codegenonly;
    dlcodeConfig.DebugMode=pvpairs.debugmode;
    dlcodeConfig.TargetDir=pvpairs.targetdir;
    dlcodeConfig.TargetFile=pvpairs.targetfile;


    if~isempty(pvpairs.targetmain)
        dlcodeConfig.CustomSource=pvpairs.targetmain;
    end


    if~isempty(dlcodeConfig.GpuConfig)
        dlcodeConfig.GpuConfig.ComputeCapability=pvpairs.computecapability;
    end


    dlcodeConfig.DeepLearningConfig.ArmComputeVersion=pvpairs.targetparams.ArmComputeVersion;
end
