function exists=existsVarOfTypeInSourceWSOf(modelName,varName,varTypeName)






    exists=false;
    if Simulink.variant.utils.existsVarInSourceWSOf(modelName,varName)
        varSplit=strsplit(varName,'.');
        classOfVar=Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(modelName,['class(',varSplit{1},');']);
        exists=~isempty(classOfVar)&&strcmp(varTypeName,classOfVar);
    end
end
