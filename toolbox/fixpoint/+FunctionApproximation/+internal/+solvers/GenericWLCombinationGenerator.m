classdef GenericWLCombinationGenerator<FunctionApproximation.internal.solvers.WLCombinationGenerator





    methods
        function wlCombinations=getCombinations(~,allowedWLs,constraints,wlUpperBounds)



            nWLs=numel(wlUpperBounds);
            combo=cell(1,nWLs);
            for iWL=1:nWLs
                if isempty(constraints{iWL})
                    combo{iWL}=intersect(allowedWLs,1:wlUpperBounds(iWL));
                    if isempty(combo{iWL})
                        combo{iWL}=allowedWLs(1);
                    end
                else
                    combo{iWL}=constraints{iWL};
                end
            end
            setCreator=FunctionApproximation.internal.CoordinateSetCreator(combo);
            wlCombinations=setCreator.CoordinateSets;
        end
    end
end


