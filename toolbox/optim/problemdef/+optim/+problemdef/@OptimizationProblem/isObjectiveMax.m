function isM=isObjectiveMax(prob)








    if isstruct(prob.Objective)&&isstruct(prob.ObjectiveSense)
        isM=structfun(@(x)strncmpi(x,"max",3),prob.ObjectiveSense);
    else
        isM=strncmpi(prob.ObjectiveSense,"max",3);
    end

end
