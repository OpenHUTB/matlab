






function[result,resultDescription,resultHandles]=runCodeAnalyzerCheck(system)

    msgGroup='ModelAdvisor:do178b:';
    checkParameter.xlateTagPrefix=msgGroup;
    [result,resultDescription,resultHandles]=slci.internal.getResultsFromMatlabCodeAnalyzer(system,checkParameter);

end
