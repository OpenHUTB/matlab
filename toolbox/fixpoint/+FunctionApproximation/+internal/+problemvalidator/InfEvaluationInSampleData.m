classdef(Sealed)InfEvaluationInSampleData<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator






    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:functionEvaluatesToInfAt'
Coordinates
    end

    methods
        function isValid=validate(this,problemDefinition)
            indices=find(isinf(problemDefinition.SampledTableData(:)));
            isValid=isempty(indices);
            if~isValid
                this.Coordinates=FunctionApproximation.internal.Utils.getCoordinates(...
                indices,...
                size(problemDefinition.SampledTableData),...
                problemDefinition.SamplingGrid);
            end
        end
    end

    methods
        function diagnostic=getDiagnostic(this,problemDefinition)
            if size(this.Coordinates,1)>5
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:functionEvaluatesToInfAtAndMore',...
                fixed.internal.compactButAccurateMat2Str(this.Coordinates(1:5,:))));
            else
                diagnostic=MException(message(this.ErrorID,...
                fixed.internal.compactButAccurateMat2Str(this.Coordinates)));
            end
            if any(problemDefinition.BoundsModifiedToType)
                diagnostic=diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:boundsModifiedToBeRepresentableByInputTypes',...
                fixed.internal.compactButAccurateMat2Str(problemDefinition.InputLowerBounds),...
                fixed.internal.compactButAccurateMat2Str(problemDefinition.InputUpperBounds))));
            end
        end
    end
end
