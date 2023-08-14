function[signalMetadata,readTable]=parseSpreadsheet(srcId,spreadSheet,allowEmpty)






    [ds,readTable]=stm.internal.util.readSpreadsheet(srcId,spreadSheet,...
    int32(stm.internal.SourceSelectionTypes.Baseline),allowEmpty);
    var=struct('VarName','ds','VarValue',ds);


    signalMetadata=stm.internal.util.getSigMetadata(var);
end
