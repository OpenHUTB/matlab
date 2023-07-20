function[parameterData,fieldIdxToParamIdxMap]=createLeafParameterData(parameters)




    sizeOfLeafs=length(parameters);

    singleParamDetails=struct('Complexity','real',...
    'Dimensions',[],...
    'DataType','',...
    'paramNameStr','',...
    'paramInitStr','',...
    'SignalPath','',...
    'Used',true,...
    'SampleTime',-1,...
    'isConstrained',false,...
    'fieldID',0);


    fieldIdxToParamIdxMap=containers.Map('KeyType','int32','ValueType','int32');
    if sizeOfLeafs==0
        parameterData=[];
        return;
    end
    parameterData(1:sizeOfLeafs)=singleParamDetails;

    paramIndex=1;
    for idx=1:length(parameters)
        noOfLeaves=length(parameters(idx).compiledInfo);
        for jdx=1:noOfLeaves
            parameterData(paramIndex)=parameters(idx).compiledInfo(jdx);
            fieldIdxToParamIdxMap(parameterData(paramIndex).fieldID)=idx;
            paramIndex=paramIndex+1;
        end
    end
end
