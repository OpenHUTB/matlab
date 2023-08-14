




function[result,resultDescription,resultHandles]=runCodeAnalyzerCheck(system)

    msgGroup='ModelAdvisor:do178b:';
    checkParameter.xlateTagPrefix=msgGroup;
    [result,resultDescription,resultHandles]=...
    ModelAdvisor.Common.modelAdvisorCheck_Mfb_MatlabCodeAnalyzer(...
    system,checkParameter);

end
