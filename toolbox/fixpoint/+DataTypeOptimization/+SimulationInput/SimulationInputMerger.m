classdef SimulationInputMerger<handle







    properties(SetAccess=private)
        ResolutionSpecification=DataTypeOptimization.SimulationInput.ConflictResolutionSpecification.empty();
    end

    properties(SetAccess=private,Hidden)
ResolutionStrategies
    end

    methods
        function this=SimulationInputMerger(resolutionSpec)

            this.ResolutionSpecification=resolutionSpec;
            this.initialize();
        end

        function mergedSI=merge(this,siLeft,siRight)

            mergedSI=Simulink.SimulationInput();


            for rIndex=1:length(this.ResolutionStrategies)
                mergedSI.(this.ResolutionStrategies(rIndex).PropertyName)=this.ResolutionStrategies(rIndex).merge(siLeft,siRight);
            end

        end

    end

    methods(Hidden)
        function initialize(this)

            this.ResolutionStrategies=DataTypeOptimization.SimulationInput.AbstractResolutionStrategy.empty(0,length(this.ResolutionSpecification.PropertyList));


            for sIndex=1:length(this.ResolutionSpecification.PropertyList)
                this.ResolutionStrategies(sIndex)=...
                DataTypeOptimization.SimulationInput.ConflictStrategyFactory.getStrategy(this.ResolutionSpecification.PropertyList(sIndex));
            end
        end
    end
end

