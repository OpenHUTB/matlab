function useFinDiff=useFiniteDifferences(obj,probStruct)







    if isstruct(obj.Equations)
        equations=struct2cell(obj.Equations);
    else
        equations={obj.Equations};
    end


    useFinDiff=false;
    if~isempty(equations)
        useFinDiff=...
        strcmp(probStruct.objectiveDerivative,"finite-differences")||...
        ~all(cellfun(@getSupportsAD,equations));
    end