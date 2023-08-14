function addIterationWithActiveSettings(testCaseObj)

    iter=sltest.testmanager.TestIteration;

    nSims=1;
    if strcmp(testCaseObj.TestType,'equivalence')
        nSims=2;
    end

    for simIndx=1:nSims

        inps=testCaseObj.getInputs(simIndx);
        if~isempty(inps)&&any([inps.Active])
            iter.setTestParam('ExternalInput',inps([inps.Active]).Name,'SimulationIndex',simIndx);
        end


        prms=testCaseObj.getParameterSets();
        if~isempty(prms)&&any([prms.Active])
            iter.setTestParam('ParameterSet',prms([prms.Active]).Name,'SimulationIndex',simIndx);
        end
    end

    if strcmp(testCaseObj.TestType,'baseline')
        bsln=testCaseObj.getBaselineCriteria();
        if~isempty(bsln)&&any([bsln.Active])
            iter.setTestParam('Baseline',bsln([bsln.Active]).Name);
        end
    end


    testCaseObj.addIteration(iter);
end
