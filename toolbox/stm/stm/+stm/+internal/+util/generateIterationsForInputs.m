function generateIterationsForInputs(testCaseID,testCaseType,tcpIndex)



    setting.paramType='ExternalInput';
    setting.simIndex=tcpIndex;
    script=stm.internal.util.generateIterationScript(setting,testCaseType);
    stm.internal.setTestCaseProperty(testCaseID,'iterationscript',script);

end

