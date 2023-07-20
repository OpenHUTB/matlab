function deActivateTestOverrides(testCaseObj)





    nSims=1;
    if strcmp(testCaseObj.TestType,'equivalence')
        nSims=2;
    end

    for simIndx=1:nSims

        tcInputs=testCaseObj.getInputs(simIndx);
        if~isempty(tcInputs)
            [tcInputs.Active]=deal(false);
        end


        tcParams=testCaseObj.getParameterSets('SimulationIndex',simIndx);
        if~isempty(tcParams)
            [tcParams.Active]=deal(false);
        end
    end


    if strcmp(testCaseObj.TestType,'baseline')
        tcBslns=testCaseObj.getBaselineCriteria;
        if~isempty(tcBslns)
            [tcBslns.Active]=deal(false);
            tcBslns(end).Active=false;

            sigCrit=arrayfun(@(bsln)bsln.getSignalCriteria,tcBslns,'UniformOutput',false);
            sigCrit=horzcat(sigCrit{:});
            [sigCrit.Enabled]=deal(true);
        end
    end

end