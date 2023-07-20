classdef Runs<handle

    methods(Static)
        function runs=runIDsToRuns(runIDs,simIndex)
            runs=Simulink.sdi.Run.empty;
            if nargin>=2
                p=inputParser;
                p.addRequired('SimulationIndex',...
                @(x)validateattributes(x,{'numeric'},...
                {'integer','scalar','<=',length(runIDs),'positive'}));
                p.parse(simIndex);

                runIDs=runIDs(simIndex);
            end

            for k=1:length(runIDs)
                runID=runIDs(k);
                myEngine=Simulink.sdi.Instance.engine;
                if myEngine.isValidRunID(runID)
                    run=Simulink.sdi.Run(myEngine,runID);
                    runs=[runs,run];
                end
            end
        end

        function externalInputRunId=createInputRunFromMatFile_DataSets(filePath)
            load(filePath);
            externalInputRunId=0;
            names=cell(length(dataSets),1);
            names(:)={'input'};
            if~isempty(dataSets)

                externalInputRunId=stm.internal.createSet();

                Simulink.sdi.addToRun(externalInputRunId,'namevalue',names,dataSets);
            end
        end

        function externalInputRunId=createInputRunFromMatFile_SignalGroup(filePath)
            load(filePath);
            externalInputRunId=0;

            if~isempty(dataSets)
                externalInputRunId=Simulink.sdi.createRun('RunName','vars',dataSets);
                Simulink.sdi.internal.moveRunToApp(externalInputRunId,'stm');
            end
        end
    end
end
