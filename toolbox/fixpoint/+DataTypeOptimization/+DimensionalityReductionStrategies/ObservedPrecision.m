classdef ObservedPrecision<DataTypeOptimization.DimensionalityReductionStrategies.DimensionalityReductionStrategy





    properties(Constant)


        ObservedPrecisionLimit=16;
        MinimumObservedPrecisionIndex=1;
        MaximumObservedPrecisionIndex=2;
    end

    methods
        function solution=processSolution(this,solution,problemPrototype,~)

            allGroups=arrayfun(@(x)(x.group),problemPrototype.dv,'UniformOutput',false);


            op=this.getObservedPrecisionForGroups(allGroups,problemPrototype.simulationScenarios);


            if~all(isinf([op(:,1);op(:,2)]))
                for gIndex=1:numel(allGroups)


                    solution.definitionDomainIndex(gIndex)=0;

                    fixedValue=-op(gIndex,1);
                    if(fixedValue<this.ObservedPrecisionLimit)&&~this.anyMATLABVariable(allGroups{gIndex})


                        fvIndex=find(problemPrototype.dv(gIndex).definitionDomain.fractionWidthVector>=fixedValue,1,'first');


                        if~isempty(fvIndex)

                            problemPrototype.dv(gIndex).definitionDomain.fractionWidthVector=fixedValue;


                            problemPrototype.dv(gIndex).definitionDomain.wordLengthVector=...
                            problemPrototype.dv(gIndex).definitionDomain.wordLengthVector(fvIndex(1));


                            solution.definitionDomainIndex(gIndex)=1;
                        end
                    end
                end
            end

        end


    end

    methods(Hidden)

        function op=getObservedPrecisionForGroups(this,allGroups,simulationScenarios)

            gop=fxptds.PrecisionInstrumentation.GroupPrecisionObserver();

            op=zeros(length(allGroups),2,length(simulationScenarios));
            for sIndex=1:length(simulationScenarios)
                modelState=Simulink.internal.TemporaryModelState(simulationScenarios(sIndex),'EnableConfigSetRefUpdate','on');
                modelState.RevertOnDelete=false;

                op(:,:,sIndex)=gop.getObservedPrecision(allGroups);
                modelState.revert;
            end


            minOP=min(op(:,this.MinimumObservedPrecisionIndex,:),[],3);
            maxOP=max(op(:,this.MaximumObservedPrecisionIndex,:),[],3);
            op=[minOP,maxOP];

        end

        function anyMLV=anyMATLABVariable(~,group)
            anyMLV=any(cellfun(@(x)(isa(x,'fxptds.MATLABVariableResult')),group.members.values));

        end
    end
end

