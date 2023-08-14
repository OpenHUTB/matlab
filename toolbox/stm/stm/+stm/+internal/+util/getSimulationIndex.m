function simIndex=getSimulationIndex(simWatcher)
    try
        permutationIds=stm.internal.getPermutations(simWatcher.testCaseId);
    catch


        simIndex=1;
        return;
    end

    if simWatcher.permutationId==permutationIds(1)
        simIndex=1;
    else
        simIndex=2;
    end
end
