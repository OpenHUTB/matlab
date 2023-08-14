classdef WLCombinationGenerator<handle






    methods(Abstract)
        wlCombinations=getCombinations(this,allowedWLs,constraints,wlUpperbound);
    end
end
