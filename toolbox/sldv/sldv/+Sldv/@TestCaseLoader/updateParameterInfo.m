function sldvData=updateParameterInfo(obj,paramsInCurrAnalysis,sldvData)















    testCases=sldvData.TestCases;
    for tcIdx=1:length(testCases)
        testCase=testCases(tcIdx);
        newTestCase=testCase;
        newTestCase.paramValues=[];
        if(isfield(testCase,'paramValues')&&...
            ~isempty(testCase.paramValues))
            prevAnalysis_params={testCase.paramValues.name};
        else
            prevAnalysis_params=[];
        end
        for paramId=1:length(paramsInCurrAnalysis)
            paramName=paramsInCurrAnalysis{paramId};
            paramLoc=find(strcmp(paramName,prevAnalysis_params));
            paramStruct.name=paramName;
            if~isempty(paramLoc)
                prevParamStruct=testCase.paramValues(paramLoc);
                paramStruct.value=prevParamStruct.value;
                paramStruct.noEffect=prevParamStruct.noEffect;
            else
                if isKey(obj.mParamDefnMap,paramName)
                    paramValue=obj.mParamDefnMap(paramName);
                else
                    paramData=evalinGlobalScope(obj.mModelH,paramName);

                    if isa(paramData,'Simulink.Parameter')
                        paramValue=paramData.Value;
                    else
                        paramValue=paramData;
                    end
                    obj.mParamDefnMap(paramName)=paramValue;
                end
                paramStruct.value=paramValue;
                paramStruct.noEffect=0;
            end
            if(isempty(newTestCase.paramValues))
                newTestCase.paramValues=paramStruct;
            else
                newTestCase.paramValues(paramId)=paramStruct;
            end
        end
        testCases(tcIdx)=newTestCase;
    end



    for idx=1:length(testCases)
        testCase=testCases(idx);
        if(isfield(testCase,'paramValues')&&...
            ~isempty(testCase.paramValues))
            testCase.paramValues=...
            Sldv.DataUtils.flattenParameters(testCase.paramValues);
        end
        testCases(idx)=testCase;
    end
    sldvData.TestCases=testCases;
end

