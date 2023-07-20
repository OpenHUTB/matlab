classdef ErrorStrategy<DataTypeOptimization.SimulationInput.AbstractResolutionStrategy






    methods
        function this=ErrorStrategy(propertyName)
            this.PropertyName=propertyName;
        end

        function siElement=execute(this,~,~)
            siElement=[];%#ok<NASGU>
            DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:conflictingSimulationInputEntries',this.PropertyName);
        end
    end

end