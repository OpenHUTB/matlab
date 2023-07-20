







function[isSlObjDefined,slObj]=getNamedObject(dataTypeName,dataAccessor)
    slObj=[];




    enumMetaClass=Simulink.getMetaClassIfValidEnumDataType(dataTypeName);
    if~isempty(enumMetaClass)
        slObj=enumMetaClass;
        isSlObjDefined=true;
        return;
    end

    varIDs=dataAccessor.name2UniqueIdWithCheck(dataTypeName);
    isSlObjDefined=~isempty(varIDs);
    if isSlObjDefined
        slObj=dataAccessor.getVariable(varIDs);
    end
end