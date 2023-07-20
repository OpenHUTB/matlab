classdef(Abstract)AnalysisCustomization<matlab.mixin.Heterogeneous




    properties(Abstract,Constant)
        Key(1,1)string;
        Name(1,1)string;
        DefaultEnabled(1,1)logical;
    end

    methods(Static,Abstract)
        [newNodeAnalyzers,newFilters]=apply(nodes,oldNodeAnalyzers,oldFilters,enabled);
    end
end
