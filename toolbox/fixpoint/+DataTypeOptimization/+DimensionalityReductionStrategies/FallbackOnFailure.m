classdef FallbackOnFailure<DataTypeOptimization.DimensionalityReductionStrategies.DimensionalityReductionStrategy




    properties
PrimaryStrategy
FallbackStrategy
    end

    methods
        function this=FallbackOnFailure(primary,fallback)
            this.PrimaryStrategy=primary;
            this.FallbackStrategy=fallback;
        end

        function finalSolution=processSolution(this,solution,problemPrototype,evaluationService)
            originalSolution=solution;

            domains=cell(1,length(problemPrototype.dv));
            for dIndex=1:length(problemPrototype.dv)
                ddm=problemPrototype.dv.definitionDomain;
                domains{dIndex}={ddm.signedness,...
                ddm.wordLengthVector,...
                ddm.fractionWidthVector,...
                ddm.slopeAdjustmentFactor,...
                ddm.bias};
            end


            finalSolution=this.PrimaryStrategy.processSolution(originalSolution,problemPrototype,evaluationService);

            for dIndex=1:length(problemPrototype.dv)
                finalSolution.definitionDomainIndex(dIndex)=1;
            end
            out=evaluationService.evaluateSolutions(finalSolution);
            if~out.isValid()

                for dIndex=1:length(problemPrototype.dv)
                    ddm=problemPrototype.dv.definitionDomain;
                    [ddm.signedness,...
                    ddm.wordLengthVector,...
                    ddm.fractionWidthVector,...
                    ddm.slopeAdjustmentFactor,...
                    ddm.bias]=deal(domains{dIndex}{:});
                end
                finalSolution=this.FallbackStrategy.processSolution(originalSolution,problemPrototype,evaluationService);
            end
        end
    end
end


