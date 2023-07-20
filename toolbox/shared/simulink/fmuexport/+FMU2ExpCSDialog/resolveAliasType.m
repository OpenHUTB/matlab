function typeName=resolveAliasType(modelName,typeName)

    try
        evaledType=Simulink.data.evalinGlobal(modelName,typeName);
        while isa(evaledType,'Simulink.AliasType')
            typeName=evaledType.BaseType;


            evaledType=Simulink.data.evalinGlobal(modelName,typeName);
        end
    catch
    end
end
