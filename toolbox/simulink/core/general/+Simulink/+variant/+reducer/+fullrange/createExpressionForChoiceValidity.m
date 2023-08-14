function netCond=createExpressionForChoiceValidity(fullRangeVarName,equalityValues,inequalityValues,blockVariantConstraints)





    netCond=Simulink.variant.reducer.fullrange.combineByAND([...
    arrayfun(@(X)([fullRangeVarName,' == ',num2str(X)]),equalityValues,'UniformOutput',false),...
    arrayfun(@(X)([fullRangeVarName,' ~= ',num2str(X)]),inequalityValues,'UniformOutput',false),...
    blockVariantConstraints]);
end
