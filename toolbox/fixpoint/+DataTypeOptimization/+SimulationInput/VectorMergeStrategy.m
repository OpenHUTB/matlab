classdef(Abstract)VectorMergeStrategy<DataTypeOptimization.SimulationInput.AbstractResolutionStrategy












    methods(Abstract,Hidden)

        c=areConflicting(this,leftElement,rightElementVector);
    end

    methods
        function elements=execute(this,siLeft,siRight)

            leftElements=siLeft.(this.PropertyName);
            rightElements=siRight.(this.PropertyName);


            for leIndex=1:length(leftElements)
                for reIndex=1:length(rightElements)
                    if this.areConflicting(leftElements(leIndex),rightElements(reIndex))

                        DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:conflictingSimulationInputVectorEntries',this.PropertyName);
                    end
                end
            end


            elements=[leftElements,rightElements];
        end
    end

end