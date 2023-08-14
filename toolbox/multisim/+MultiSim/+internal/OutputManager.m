







classdef OutputManager<handle
    properties(Access=private)
SimulationOutputIndexer
SimulationFinishedHandler
    end

    events
SimulationOutputFormatted
    end

    methods
        function obj=OutputManager(simManager)
            obj.SimulationFinishedHandler=addlistener(simManager,'SimulationFinished',@(~,eventData)obj.handleSimulationFinished(eventData));
        end

        function update(obj,simManager)
            if~isempty(simManager.SimulationData)
                outputData=struct('name',{},'data',{});
                outputDataEvent=repmat(struct('runId',0,'values',outputData),1,numel(simManager.SimulationData));
                fieldNames={};
                for i=1:numel(simManager.SimulationData)
                    outputDataEvent(i).runId=i;

                    simData=simManager.SimulationData{i};
                    outputIdentifiers=fieldnames(simData);

                    if isempty(outputIdentifiers)
                        continue;
                    end

                    if isempty(fieldNames)
                        simOutExtractors=MultiSim.internal.getSimulationOutputExtractors(simData);
                        if~isempty(simOutExtractors)
                            obj.SimulationOutputIndexer=MultiSim.internal.SimulationOutputIndexer(simOutExtractors);
                            fieldNames=obj.SimulationOutputIndexer.Keys;
                        end
                    end

                    outputData=obj.getOutputDataForFields(simData,fieldNames);
                    outputDataEvent(i).values=outputData;
                end

                evtData=MultiSim.internal.SimulationManagerEventData(outputDataEvent);
                notify(obj,'SimulationOutputFormatted',evtData);
            end
        end

        function delete(obj)
            delete(obj.SimulationFinishedHandler);
        end
    end

    methods(Access=private)




        function outputData=fillOutputData(obj,simOut)
            outputData=struct('name',{},'data',{});
            if~isempty(obj.SimulationOutputIndexer)
                fieldNames=obj.SimulationOutputIndexer.Keys;
                [simData,~]=simOut.getInternalSimulationDataAndMetadataStructs();
                outputData=obj.getOutputDataForFields(simData{1},fieldNames);
            end
        end

        function outputData=getOutputDataForFields(obj,simData,fieldNames)
            outputData=repmat(struct('name',"",'data',0),1,numel(fieldNames));
            for fieldIndex=1:numel(fieldNames)
                curName=fieldNames{fieldIndex};
                outputExtractor=obj.SimulationOutputIndexer.getExtractor(curName);
                curData=outputExtractor.getData(simData);
                outputData(fieldIndex)=struct('name',curName,'data',curData);
            end
        end



        function handleSimulationFinished(obj,eventData)
            runId=eventData.RunId;
            simOut=eventData.SimulationOutput;
            if~isempty(simOut.ErrorMessage)
                return;
            end
            outputIdentifiers=who(simOut);


            if isempty(obj.SimulationOutputIndexer)&&~isempty(outputIdentifiers)
                [simData,~]=simOut.getInternalSimulationDataAndMetadataStructs();
                simOutExtractors=MultiSim.internal.getSimulationOutputExtractors(simData{1});
                if~isempty(simOutExtractors)





                    obj.SimulationOutputIndexer=MultiSim.internal.SimulationOutputIndexer(simOutExtractors);
                end
            end
            outputData=fillOutputData(obj,simOut);
            outputDataEvent=struct('runId',runId,'values',outputData);
            evtData=MultiSim.internal.SimulationManagerEventData(outputDataEvent);
            notify(obj,'SimulationOutputFormatted',evtData);
        end
    end
end
