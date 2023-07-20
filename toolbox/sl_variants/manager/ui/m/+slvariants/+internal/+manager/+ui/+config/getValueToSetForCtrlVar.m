function valueToSet=getValueToSetForCtrlVar(modelName,value)





    if isa(value.Value,'Simulink.data.Expression')
        valueToSet=value.Value.ExpressionString;
        try

            valueToSet=evalinGlobalScope(modelName,valueToSet);
        catch
            valueToSet=0;
        end
    else
        valueToSet=value.Value;



        dataTypeStr=slvariants.internal.manager.ui.config.getDataTypeForSlParam(modelName,value);

        if(strcmp(dataTypeStr,'auto')||startsWith(dataTypeStr,'Enum:'))
            return;
        end

        if startsWith(dataTypeStr,'fixdt')


            dataType=eval(dataTypeStr);
            valueToSet=fi(valueToSet,dataType);
            return;
        end

        try

            valueToSet=cast(valueToSet,dataTypeStr);
        catch



        end

    end
end
