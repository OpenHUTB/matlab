classdef ModelPropertyMergeStrategy<DataTypeOptimization.SimulationInput.VectorMergeStrategy







    methods
        function this=ModelPropertyMergeStrategy(propertyName)
            this.PropertyName=propertyName;
        end
    end

    methods(Hidden)
        function c=areConflicting(~,leftElement,rightElement)

            sameName=isequal(rightElement.Name,leftElement.Name);


            diffValue=~isequal(rightElement.Value,leftElement.Value);


            c=sameName&diffValue;
        end
    end
end

