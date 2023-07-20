function F=tableValueOptimizationObjective(tv,f_true,approximation,tableData,testSets,linearIndices,normOrder,errorBound)









    tableData{end}(linearIndices)=tv;
    serializeableData=approximation.Data;
    serializeableData.Data=tableData;
    modify(approximation,serializeableData);
    f_lut=approximation.evaluate(testSets);
    evaluationDiff=f_true-f_lut;
    evaluationDiffToErrorBoundRatio=abs(evaluationDiff)./errorBound;
    F=norm(evaluationDiffToErrorBoundRatio,normOrder);
end
