









function pvpairs=paramsValidation(pvpairs)

    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.KeepUnmatched=true;
    pObj.PartialMatching=false;
    params=pvpairs.targetparams;

    addParameter(pObj,'UseShippingLibs',-1);

    parse(pObj,params);

    pvpairs.targetparams=pObj.Results;


    unmatchedParams=fields(pObj.Unmatched);
    for k=1:numel(unmatchedParams)
        error(message('gpucoder:cnncodegen:unsupported_parameter_name',unmatchedParams{k},'MKLDNN'));
    end
end
