function simulinkDataTypeObjectsInGlobalScope=getSimulinkDataTypeObjects(modelName)






    dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);




    numericTypeIDs=dataAccessor.identifyVisibleVariablesByClass('Simulink.NumericType');
    aliasTypeIDs=dataAccessor.identifyVisibleVariablesByClass('Simulink.AliasType');
    objectIDs=[numericTypeIDs;aliasTypeIDs];
    simulinkDataTypeObjectsInGlobalScope=getNameValuePairs(dataAccessor,objectIDs);
end



function objectNameValuePair=getNameValuePairs(dataAccessor,objectIDs)
    objectNameValuePair=repmat(struct('Name',{{}},'Object',{{}}),numel(objectIDs),1);
    for i=1:numel(objectIDs)
        objectNameValuePair(i,1).Name=objectIDs(i).Name;
        objectNameValuePair(i,1).Object=dataAccessor.getVariable(objectIDs(i));
    end
end
