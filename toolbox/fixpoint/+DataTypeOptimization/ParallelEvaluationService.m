classdef ParallelEvaluationService<DataTypeOptimization.AbstractEvaluationService

    properties
baselineComparisonUtil
simulationInputCreator
    end

    methods

        function solutions=evaluateSolutions(this,solutions)


            this.getSimulationInputs(solutions);


            this.castToParsim(solutions);



            DataTypeOptimization.Parallel.Utils.exportSolutions(solutions);

        end

        function delete(this)

            this.handleWarnings('on');
        end

    end

    methods(Hidden)

        function handleWarnings(~,setting)

            warning(setting,'Simulink:Commands:SimulationsWithErrors')
            warning(setting,'SDI:sdi:notValidBaseWorkspaceVar')
            warning(setting,'Simulink:slbuild:unsavedMdlRefsCause');
            warning(setting,'Simulink:slbuild:unsavedMdlRefsAllowed');
        end

        function initializeParameters(this,parsedResults)

            this.handleWarnings('off');

            this.problemPrototype=parsedResults.ProblemPrototype;
            this.environmentProxy=parsedResults.EnvironmentProxy;
            this.baselineSimOut=parsedResults.BaselineSimOut;
            this.baselineRunID=parsedResults.BaselineRunID;
            siEntriesMap=parsedResults.SimulationInputEntriesMap;
            prepSimIn=parsedResults.PreprocessingInput;


            this.baselineSimOut=this.baselineSimOut.setUserString(...
            DataTypeOptimization.BaselineProperties.RunName);
            if~isempty(this.baselineRunID)
                for sIndex=1:length(this.baselineSimOut)
                    run=Simulink.sdi.getRun(this.baselineRunID(sIndex));
                    run.Name=[DataTypeOptimization.BaselineProperties.RunName,sprintf('_%i',sIndex)];
                end
            end

            options=parsedResults.OptimizationOptions;
            this.baselineComparisonUtil=DataTypeOptimization.SDIBaselineComparison();
            this.baselineComparisonUtil.bindConstraints(this.baselineRunID,options.Constraints.values);


            this.simulationInputCreator=DataTypeOptimization.Parallel.SimulationInputCreator(...
            siEntriesMap,...
            this.environmentProxy.context.AllModels,...
            options,...
            this.baselineSimOut,...
            prepSimIn);

        end

        function simOut=castToParsim(this,solutions)
            si=Simulink.SimulationInput.empty();
            for sIndex=1:length(solutions)
                si=[si,solutions(sIndex).simIn];%#ok<AGROW>
            end


            this.setDirty('off');
            simOut=parsim(si,'ShowSimulationManager','off','ShowProgress','off','TransferBaseWorkspaceVariables','on');
            this.setDirty('on');

            numScenarios=length(solutions(1).simIn);
            simOutSplit=reshape(simOut,numScenarios,length(simOut)/numScenarios);

            for sIndex=1:size(simOutSplit,2)
                solutions(sIndex).simOut=simOutSplit(:,sIndex)';
            end
        end

        function setDirty(this,dirtyValue)



            for mIndex=1:numel(this.environmentProxy.context.AllModels)
                set_param(this.environmentProxy.context.AllModels{mIndex},'Dirty',dirtyValue);
            end
        end

        function getSimulationInputs(this,solutions)



            for sIndex=1:numel(solutions)
                this.simulationInputCreator.getSimulationInput(this.problemPrototype,solutions(sIndex));
            end
        end
    end
end


