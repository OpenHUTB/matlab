function isM=isObjectiveMax(prob)










    if isstruct(prob.Equations)
        numLabels=numel(fieldnames(prob.Equations));
        isM=false(numLabels,1);
    else
        isM=false;
    end

end
