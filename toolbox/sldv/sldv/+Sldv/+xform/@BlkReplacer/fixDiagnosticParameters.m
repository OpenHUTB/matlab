function fixDiagnosticParameters(obj)




    modelH=get_param(obj.MdlInfo.ModelH,'Handle');

    paramValues={};
    paramsToTurnOff=obj.MdlInfo.DiagnosticsToTurnOff;
    if~isempty(paramsToTurnOff)
        numParams=length(paramsToTurnOff);
        paramValues=cell(1,2*numParams);
        paramValues(1:2:(2*numParams-1))=paramsToTurnOff;
        modelObj=get_param(modelH,'Object');
        for idx=1:numParams
            allowedValues=modelObj.getPropAllowedValues(paramsToTurnOff{idx});
            if isempty(allowedValues)||any(strcmp('none',allowedValues))
                newValue='none';
            elseif any(strcmp('warning',allowedValues))
                newValue='warning';
            else
                assert(false);
            end
            paramValues{2*idx}=newValue;
        end
    end

    if~isempty(paramValues)
        Sldv.xform.maskUtils.safeSetParamBlk(modelH,paramValues{:});
    end
end