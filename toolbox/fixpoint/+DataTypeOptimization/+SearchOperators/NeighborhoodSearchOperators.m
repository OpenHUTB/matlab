classdef NeighborhoodSearchOperators<handle






    methods(Static)

        function solution=increment(problemPrototype,solution,shiftAmountVector)




            for dIndex=1:length(problemPrototype.dv)
                if shiftAmountVector(dIndex)
                    solution=DataTypeOptimization.SearchOperators.NeighborhoodSearchOperators.incrementSingle(problemPrototype,solution,dIndex,shiftAmountVector(dIndex));
                end
            end
        end

        function solution=incrementSingle(problemPrototype,solution,dIndex,shiftAmount)



            index=solution.definitionDomainIndex(dIndex)+shiftAmount;


            if index<1
                index=1;
            elseif index>length(problemPrototype.dv(dIndex).definitionDomain.fractionWidthVector)
                index=length(problemPrototype.dv(dIndex).definitionDomain.fractionWidthVector);
            end



            solution.definitionDomainIndex(dIndex)=index;
        end
    end
end