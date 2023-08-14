classdef BlockPropertyMergeStrategy<DataTypeOptimization.SimulationInput.VectorMergeStrategy








    methods
        function this=BlockPropertyMergeStrategy(propertyName)
            this.PropertyName=propertyName;
        end
    end

    methods(Hidden)
        function c=areConflicting(~,leftElement,rightElement)

            sameBlockPath=isequal(rightElement.BlockPath,leftElement.BlockPath);


            sameName=isequal(rightElement.Name,leftElement.Name);




            diffValue=~isequal(rightElement.Value,leftElement.Value);


            c=sameBlockPath&sameName&diffValue;

        end
    end
end

