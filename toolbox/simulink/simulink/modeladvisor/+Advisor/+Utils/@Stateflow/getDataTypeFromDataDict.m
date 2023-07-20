function dataType=getDataTypeFromDataDict(system,idName)




    dataType='';
    dataAccessor=Simulink.data.DataAccessor.create(system);
    varId=dataAccessor.identifyByName(idName);
    if~isempty(varId)
        val=dataAccessor.getVariable(varId);
        className=class(val);
        switch(className)
        case 'Simulink.data.dictionary.EnumTypeDefinition'
            dataType=val.StorageType;
        otherwise
            dataType='unknown';
        end
    end
end
