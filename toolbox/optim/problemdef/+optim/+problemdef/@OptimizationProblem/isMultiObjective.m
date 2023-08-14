function ism=isMultiObjective(prob)








    objective=prob.Objective;


    if isstruct(objective)
        numLabelledObj=structfun(@numel,objective);
        numObjectives=sum(numLabelledObj);
    else
        numObjectives=numel(objective);
    end


    ism=numObjectives>1;

end