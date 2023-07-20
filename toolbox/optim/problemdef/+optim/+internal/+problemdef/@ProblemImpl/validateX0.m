function validateX0(prob,x0)










    if isa(x0,'optim.problemdef.OptimizationValues')


        try
            checkSamePropertiesAsProblem(x0,prob);
        catch ME
            throwAsCaller(ME);
        end
    elseif~isempty(x0)


        optim.internal.problemdef.checkEvaluateInputs(prob,x0,...
        'optim_problemdef:ProblemImpl:solve',prob.MessageCatalogID+":solve");
    end
