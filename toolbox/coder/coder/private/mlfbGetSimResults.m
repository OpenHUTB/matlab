function[ranges,expressions,coverageInfo,errorMessage,messages]=mlfbGetSimResults(dataAdapter)




    [ranges,expressions,coverageInfo,errorMessage,messages]=...
    coder.internal.MLFcnBlock.Float2FixedManager.getSimulationResults(char(dataAdapter.getFunctionBlockSid()));
end