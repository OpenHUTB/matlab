classdef ConflictStrategyFactory<handle







    methods(Static)
        function strategy=getStrategy(strategySpecification)
            propertyName=strategySpecification.PropertyName;
            switch strategySpecification.ConflictMode
            case DataTypeOptimization.SimulationInput.ConflictMode.Error
                strategy=DataTypeOptimization.SimulationInput.ErrorStrategy(propertyName);
            case DataTypeOptimization.SimulationInput.ConflictMode.Merge
                switch propertyName
                case 'UserString'
                    strategy=DataTypeOptimization.SimulationInput.UserStringMergeStrategy(propertyName);
                case 'ModelParameters'
                    strategy=DataTypeOptimization.SimulationInput.ModelPropertyMergeStrategy(propertyName);
                case 'BlockParameters'
                    strategy=DataTypeOptimization.SimulationInput.BlockPropertyMergeStrategy(propertyName);
                case 'Variables'
                    strategy=DataTypeOptimization.SimulationInput.VariablesMergeStrategy(propertyName);
                otherwise




                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:missingMergingResolutionStrategy',propertyName);

                end
            end
        end
    end
end

