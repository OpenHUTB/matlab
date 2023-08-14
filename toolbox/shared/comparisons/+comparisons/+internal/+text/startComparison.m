function startComparison(leftSource,rightSource)




    sel=com.mathworks.comparisons.selection.ComparisonSelection(leftSource,rightSource);
    allowMerging=com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging.getInstance();
    sel.setValue(allowMerging,java.lang.Boolean.FALSE)
    sel.setComparisonType(com.mathworks.comparisons.register.type.ComparisonTypeText());


    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(sel);
end
