function dataTypeStr=getDataTypeForSlParam(modelName,value)




    dataTypeStr=value.DataType;
    dataAcc=Simulink.data.DataAccessor.createForExternalData(modelName);

    if dataAcc.hasVariable(dataTypeStr)





        aliasTypeId=dataAcc.identifyByName(dataTypeStr);
        aliasType=dataAcc.getVariable(aliasTypeId);

        if isa(aliasType,'Simulink.AliasType')
            dataTypeStr=aliasType.BaseType;
        elseif isa(aliasType,'Simulink.NumericType')
            if~isfixed(aliasType)
                dataTypeStr=qpointstr(aliasType);
            else
                dataTypeStr=aliasType.tostring;
            end
        end
    end


    if strcmp(dataTypeStr,'boolean')
        dataTypeStr='logical';
    end
end
