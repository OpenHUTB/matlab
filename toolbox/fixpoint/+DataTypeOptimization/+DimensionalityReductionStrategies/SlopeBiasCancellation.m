classdef SlopeBiasCancellation<DataTypeOptimization.DimensionalityReductionStrategies.DimensionalityReductionStrategy




    properties
maxTime
    end

    methods
        function obj=SlopeBiasCancellation(maxTime)
            if nargin==0
                obj.maxTime=600;
            else
                obj.maxTime=maxTime;
            end
        end

        function solution=processSolution(this,solution,problemPrototype,~)
            cpModel=cpopt.internal.CPModel;
            cpModel.MaxTime=this.maxTime;


            variables=problemPrototype.constraintVariables;
            for varIndex=1:length(variables)
                var=variables{varIndex};
                if var.isKnown()
                    cpModel.addVariable(var.ID,var.SlopeAdjustmentFactor,var.Bias);
                else
                    cpModel.addVariable(var.ID);
                end
            end


            constraints=problemPrototype.slopeBiasConstraints;
            for constraintIndex=1:length(constraints)
                constraint=constraints{constraintIndex};
                constraint.apply(cpModel);
            end


            cpModel.solve();


            groups={problemPrototype.dv.group};
            for gIndex=1:numel(groups)
                varName=num2str(groups{gIndex}.id);

                slope=1;
                bias=0;
                if cpModel.isSlopeKnown(varName)
                    slope=cpModel.getSlopeForVariable(varName);
                end
                if cpModel.isBiasKnown(varName)
                    bias=cpModel.getBiasForVariable(varName);
                end

                domain=problemPrototype.dv(gIndex).definitionDomain;
                saf=slope/2^floor(log2(slope));

                domain.setSlopeAndBias(saf,bias);
            end
        end
    end
end


