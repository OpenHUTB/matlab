classdef VariablesMergeStrategy<DataTypeOptimization.SimulationInput.VectorMergeStrategy








    methods
        function this=VariablesMergeStrategy(propertyName)
            this.PropertyName=propertyName;
        end
    end

    methods(Hidden)
        function c=areConflicting(~,leftElement,rightElement)

            sameName=isequal(rightElement.Name,leftElement.Name);


            sameWorkspace=isequal(rightElement.Workspace,leftElement.Workspace);


            diffValue=~isequal(rightElement.Value,leftElement.Value);


            c=sameWorkspace&sameName&diffValue;

        end
    end
end

