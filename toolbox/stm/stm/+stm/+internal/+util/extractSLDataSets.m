function[inDataSets,outDataSets,paramVariables]=extractSLDataSets(sldvData,decimate,extractInfo)







    stmSldvInput=Sldv.DataUtils.convertTestCasesToSLDataSet(sldvData,decimate);
    simData=Sldv.DataUtils.getSimData(stmSldvInput);
    numTestCases=length(simData);
    inDataSets=Simulink.SimulationData.Dataset.empty(numTestCases,0);
    outDataSets=Simulink.SimulationData.Dataset.empty(numTestCases,0);
    paramVariables=cell(numTestCases,0);
    for idx=1:numTestCases
        testCase=simData(idx);
        if(isfield(testCase,'dataValues')&&...
            ~isempty(testCase.dataValues)&&extractInfo(1))
            inDataSets(idx)=testCase.dataValues;
        end
        if(isfield(testCase,'expectedOutput')&&...
            ~isempty(testCase.expectedOutput)&&extractInfo(2))
            outDataSets(idx)=testCase.expectedOutput;
        end
        if(isfield(testCase,'paramValues')&&...
            ~isempty(testCase.paramValues)&&extractInfo(3))
            paramVariables{idx}=extractParamsToVariables(testCase.paramValues);
        end
    end
end

function paramVariable=extractParamsToVariables(paramValues)
    if(~isempty(paramValues))
        paramLength=length(paramValues);
        paramVariable=Simulink.Simulation.Variable.empty(paramLength,0);
        for idx=1:paramLength
            paramVariable(idx)=Simulink.Simulation.Variable(paramValues(idx).name,paramValues(idx).value);
        end
    else
        paramVariable=Simulink.Simulation.Variable.empty();
    end
end
