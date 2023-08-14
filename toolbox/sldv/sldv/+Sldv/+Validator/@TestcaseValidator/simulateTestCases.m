function simData=simulateTestCases(obj,testCases,modelToSimulate)%#ok<INUSD>




    if nargin<2
        modelToSimulate=obj.modelH;%#ok<NASGU>
    end

    numTestCases=numel(testCases);
    futureIdToTcIdxMap=containers.Map('KeyType','double','ValueType','any');

    try
        obj.mProfileLogger.openPhase('Simulate Testcases');
        obj.mProfileLogger.logPhaseInfo('size',length(testCases));
        simData=obj.runTestObj.runSimulation(testCases);



        if isa(simData,'Simulink.Simulation.Future')
            for simIdx=1:numTestCases
                futureIdToTcIdxMap(simData(simIdx).ID)=simIdx;
            end
        end
        obj.FutureIdMapForTestcases=futureIdToTcIdxMap;
        obj.mProfileLogger.closePhase('Simulate Testcases');
    catch Mex %#ok<NASGU>
        obj.mProfileLogger.closePhase('Simulate Testcases');




        simData=repmat(-1,1,numTestCases);
        obj.FutureIdMapForTestcases=containers.Map('KeyType','double','ValueType','any');
    end
end
