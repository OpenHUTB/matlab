









function pvpairs=paramsValidation(pvpairs)

    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.KeepUnmatched=true;
    pObj.PartialMatching=false;
    params=pvpairs.targetparams;



    addParameter(pObj,'autotuning',true);
    addParameter(pObj,'datatype','fp32');
    addParameter(pObj,'CalibrationResultFile','');

    parse(pObj,params);

    pvpairs.targetparams=pObj.Results;
    pvpairs.targetparams.datatype=upper(pvpairs.targetparams.datatype);



    unmatchedParams=fields(pObj.Unmatched);
    for k=1:numel(unmatchedParams)
        error(message('gpucoder:cnncodegen:unsupported_parameter_name',unmatchedParams{k},'cudnn'));
    end
end
