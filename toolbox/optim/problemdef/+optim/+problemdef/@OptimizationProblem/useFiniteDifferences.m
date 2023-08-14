function useFinDiff=useFiniteDifferences(obj,probStruct)









    if isstruct(obj.Objective)
        fnames=fieldnames(obj.Objective);
        objective=obj.Objective.(fnames{1});
    else
        objective=obj.Objective;
    end
    if isstruct(obj.Constraints)
        constraints=struct2cell(obj.Constraints);
    else
        constraints={obj.Constraints};
    end


    useFinDiff=false;
    if~isempty(objective)
        useFinDiff=...
        strcmp(probStruct.objectiveDerivative,"finite-differences")||...
        ~getSupportsAD(objective);
    end
    if~isempty(constraints)
        useFinDiff=useFinDiff||...
        strcmp(probStruct.constraintDerivative,"finite-differences")||...
        ~all(cellfun(@getSupportsAD,constraints));
    end