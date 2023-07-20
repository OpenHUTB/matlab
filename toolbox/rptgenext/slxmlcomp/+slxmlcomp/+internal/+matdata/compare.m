function compare(leftFilePath,leftVariablePath,rightFilePath,rightVariablePath,comparisonParameters)




    vs1=createVariableComparisonSource(leftFilePath,leftVariablePath,'_first');
    vs2=createVariableComparisonSource(rightFilePath,rightVariablePath,'_second');
    selection=com.mathworks.comparisons.selection.ComparisonSelection(vs1,vs2);
    selection.addAll(comparisonParameters);

    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(selection);
end


function comparisonSource=createVariableComparisonSource(filePath,variablePath,suffix)
    reference=slxmlcomp.internal.matdata.load(filePath,variablePath,suffix);
    [~,fileName]=fileparts(filePath);
    sourceName=[fileName,suffix,'.',variablePath];
    comparisonSource=com.mathworks.comparisons.source.impl.VariableSource(...
    sourceName,...
    ['evalin(''base'',''',reference,''')'],...
    ['comparisons_private(''varcleanup'',''',reference,''')']);

    slxmlcomp.internal.matdata.MatDataCache.remove(filePath);
end
