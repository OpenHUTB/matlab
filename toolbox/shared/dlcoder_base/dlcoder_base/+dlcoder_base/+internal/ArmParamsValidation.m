












function pvpairs=ArmParamsValidation(pvpairs,targetname)




    if(pvpairs.batchsize~=1)
        if(strcmp(pvpairs.targetlib,'arm-compute-mali'))||...
            (strcmp(pvpairs.targetlib,'arm-compute')&&~dlcoderfeature('BatchSizeSupportForARMCompute'))
            supportedValuesStr=string(message('gpucoder:cnncodegen:supported_values','''1'''));
            error(message('gpucoder:cnncodegen:invalid_parameter_value_target',pvpairs.batchsize,'batchsize',targetname,supportedValuesStr));
        end
    end

    pvpairs.codegenonly=1;
    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.KeepUnmatched=true;
    pObj.PartialMatching=false;
    params=pvpairs.targetparams;

    if~strcmp(pvpairs.targetlib,'arm-compute-mali')
        if~(dlcoderfeature('SupportACLVersionV2011'))
            addParameter(pObj,'ArmComputeVersion','20.02.1');
        else
            addParameter(pObj,'ArmComputeVersion','20.11');
        end
        addParameter(pObj,'ArmArchitecture','');
        addParameter(pObj,'datatype','fp32',@(x)checkVal(x,{'fp32','int8'},'''fp32'' and ''int8'''));
        addParameter(pObj,'CalibrationResultFile','');
    else
        addParameter(pObj,'ArmComputeVersion','19.05');
    end

    parse(pObj,params);

    pvpairs.targetparams=pObj.Results;



    unmatchedParams=fields(pObj.Unmatched);
    for k=1:numel(unmatchedParams)
        error(message('gpucoder:cnncodegen:unsupported_parameter_name',unmatchedParams{k},pvpairs.targetlib));
    end
end

function checkVal(value,supportedValues,supportedValuesStr)
    value=convertStringsToChars(value);
    flag=ismember(value,supportedValues);
    if~flag&&~isempty(supportedValuesStr)
        error(message('gpucoder:cnncodegen:supported_values',supportedValuesStr));
    end
end
