classdef ModelRefParameterApplicator<handle










    properties(SetAccess=private)
simulationInput
modelState
    end

    methods
        function this=ModelRefParameterApplicator(environmentContext,modelParameters)

            this.simulationInput=Simulink.SimulationInput.empty(0,numel(environmentContext.AllModels));
            for mIndex=1:numel(environmentContext.AllModels)
                this.simulationInput(mIndex)=...
                Simulink.SimulationInput(environmentContext.AllModels{mIndex});
                this.simulationInput(mIndex).ModelParameters=...
                modelParameters;

            end

        end

        function applyParameters(this)

            this.modelState=Simulink.internal.TemporaryModelState.empty(0,numel(this.simulationInput));
            for mIndex=1:numel(this.simulationInput)
                this.modelState(mIndex)=Simulink.internal.TemporaryModelState(this.simulationInput(mIndex),'EnableConfigSetRefUpdate','on');
                this.modelState(mIndex).RevertOnDelete=false;
            end

        end

        function revertParameters(this)

            for mIndex=1:numel(this.modelState)
                this.modelState(mIndex).revert();

            end
        end

        function delete(this)

            this.revertParameters();
        end
    end
end

