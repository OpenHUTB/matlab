classdef BitWidthSumObjective<DataTypeOptimization.Objectives.AbstractObjective






    methods
        function validate(~)

        end

        function cost=measure(this,solution)



            cost=0;
            for dIndex=1:numel(this.decisionVariablesCount)

                currentCount=double(this.decisionVariablesCount(dIndex));
                currentCost=currentCount*128;
                domainIndex=solution.definitionDomainIndex(dIndex);
                if domainIndex
                    currentCost=this.definitionDomains(dIndex).wordLengthVector(domainIndex)*currentCount;
                end

                cost=cost+currentCost;
            end
        end

    end
end

