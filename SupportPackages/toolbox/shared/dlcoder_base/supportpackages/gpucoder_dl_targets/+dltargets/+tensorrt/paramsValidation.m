









function pvpairs=paramsValidation(pvpairs)

    pObj=inputParser;
    pObj.CaseSensitive=false;
    pObj.KeepUnmatched=true;
    pObj.PartialMatching=false;
    params=pvpairs.targetparams;

    addParameter(pObj,'datatype','fp32');
    addParameter(pObj,'datapath','');
    addParameter(pObj,'numCalibrationBatches',0);

    parse(pObj,params);

    pvpairs.targetparams=pObj.Results;
    pvpairs.targetparams.datatype=upper(pvpairs.targetparams.datatype);


    if strcmpi(pvpairs.targetparams.datatype,'int8')&&(pvpairs.targetparams.numCalibrationBatches==0)
        pvpairs.targetparams.numCalibrationBatches=50;
    end


    unmatchedParams=fields(pObj.Unmatched);
    for k=1:numel(unmatchedParams)
        error(message('gpucoder:cnncodegen:unsupported_parameter_name',unmatchedParams{k},'TensorRT'));
    end
end
