function exists=existsVarInSourceWSOf(modelName,varName)






    exists=false;
    if contains(varName,'.')

        varSplit=strsplit(varName,{'.','(','{'});
        if existsInGlobalScope(modelName,varSplit{1})

            if Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(modelName,['isstruct(',varSplit{1},')'])
                baseStructName=varSplit{1};
                exists=Simulink.variant.utils.existsVarStructFields(modelName,varName,baseStructName);
            end
        end
    else
        exists=isvarname(varName)&&existsInGlobalScope(modelName,varName);
    end
end
