function tcDataStruct=getFlatParamTCData(IOStruct,testCaseStruct)




    try
        testComp=Sldv.Token.get.getTestComponent;
        tcDataStruct=[];
        parameterData=createLeafParameterData(testComp.mdlFlatIOInfo.Parameter);
        fieldIdxToParamIdxMap=containers.Map({parameterData.fieldID},1:length(parameterData));
        noOfParamsInAnalysis=length(IOStruct);
        testCaseParamsMap=containers.Map({testCaseStruct.name},1:length(testCaseStruct));
        flatDataIdx=1;

        modelH=testComp.analysisInfo.analyzedModelH;
        dataAccessor=Simulink.data.DataAccessor.create(modelH);

        for idx=1:noOfParamsInAnalysis


            nameInAnalysis=IOStruct(idx).paramName;
            leavesInAnalysis=IOStruct(idx).analysisInterfaces;
            noOfLeavesInAnalysis=length(leavesInAnalysis);
            if isParamNewlyAdded(testCaseParamsMap,nameInAnalysis)



                tcForCurrentParam=createDefaultTestCase(nameInAnalysis,dataAccessor);
            else
                paramIdxInData=testCaseParamsMap(nameInAnalysis);
                tcForCurrentParam=testCaseStruct(paramIdxInData);
            end


            if~isstruct(tcForCurrentParam.value)&&(noOfLeavesInAnalysis==1)



                if flatDataIdx==1
                    tcDataStruct=struct('name',tcForCurrentParam.name,...
                    'value',tcForCurrentParam.value,...
                    'noeffect',0,...
                    'nameInAnalysis',nameInAnalysis,...
                    'dvID',leavesInAnalysis.mID);
                else
                    tcDataStruct(flatDataIdx)=struct('name',tcForCurrentParam.name,...
                    'value',tcForCurrentParam.value,...
                    'noeffect',0,...
                    'nameInAnalysis',nameInAnalysis,...
                    'dvID',leavesInAnalysis.mID);%#ok<AGROW>
                end

                flatDataIdx=flatDataIdx+1;
                continue;
            end
            flatTCParam=flattenTCParam(tcForCurrentParam.value,tcForCurrentParam.name);
            flatTCLeafNameMap=containers.Map({flatTCParam.paramName},1:length(flatTCParam));
            for jdx=1:noOfLeavesInAnalysis
                dvID=leavesInAnalysis(jdx).mID;
                nameInAnalysis=leavesInAnalysis(jdx).name;
                leafID=fieldIdxToParamIdxMap(dvID);
                currentParameterCompiledInfo=parameterData(leafID);


                leafNameInCompiledInfo=currentParameterCompiledInfo.paramNameStr;
                if~flatTCLeafNameMap.isKey(leafNameInCompiledInfo)


                    leafValue=getDefaultValForLeaf(tcForCurrentParam.name,currentParameterCompiledInfo,dataAccessor);
                else
                    flatTCIdx=flatTCLeafNameMap(leafNameInCompiledInfo);
                    leafValue=flatTCParam(flatTCIdx).paramValue;
                end
                if flatDataIdx==1
                    tcDataStruct=struct('name',leafNameInCompiledInfo,...
                    'value',leafValue,...
                    'noeffect',0,...
                    'nameInAnalysis',nameInAnalysis,...
                    'dvID',leavesInAnalysis(jdx).mID);
                else
                    tcDataStruct(flatDataIdx)=struct('name',leafNameInCompiledInfo,...
                    'value',leafValue,...
                    'noeffect',0,...
                    'nameInAnalysis',nameInAnalysis,...
                    'dvID',leavesInAnalysis(jdx).mID);%#ok<AGROW>
                end

                flatDataIdx=flatDataIdx+1;
            end
        end
    catch Mex


        tcDataStruct=[];
    end
end

function tcForCurrentLeaf=getDefaultValForLeaf(paramName,compiledInfo,dataAccessor)
    try
        topParamVal=createDefaultTestCase(paramName,dataAccessor);%#ok<NASGU>
        paramNameSplit=strsplit(compiledInfo.paramInitStr,'.');
        paramNameSplit{1}='topParamVal.value';
        paramNameToEval=strjoin(paramNameSplit,'.');
        tcForCurrentLeaf=eval(paramNameToEval);
    catch Mex %#ok<NASGU>


        tcForCurrentLeaf=0;
    end

end

function tcForCurrentParam=createDefaultTestCase(paramName,dataAccessor)

    tcForCurrentParam.name=paramName;
    varId=dataAccessor.identifyByName(paramName);
    tcForCurrentParam.value=dataAccessor.getVariable(varId);
end

function retVal=isParamNewlyAdded(testCaseParamsMap,topParamName)








    retVal=~(testCaseParamsMap.isKey(topParamName));
end

function flatTCParam=flattenTCParam(paramValue,paramName)
    flatTCParam=[];
    if~isstruct(paramValue)
        flatTCParam=struct('paramName',paramName,'paramValue',paramValue);
        return;
    end
    fields=fieldnames(paramValue);
    for idx=1:length(fields)
        currentFieldVal=paramValue.(fields{idx});
        currentParamName=[paramName,'.',fields{idx}];
        flattenedParamsForCurrentField=flattenTCParam(currentFieldVal,currentParamName);
        flatTCParam=[flatTCParam,flattenedParamsForCurrentField];%#ok<AGROW>
    end
end
