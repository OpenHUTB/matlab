function id=getLoggedSignalSet(simInput)

    if~isempty(simInput.TestIteration.TestParameter.LoggedSignalSetId)
        id=simInput.TestIteration.TestParameter.LoggedSignalSetId;
    elseif simInput.LoggedSignalSetId>0
        id=simInput.LoggedSignalSetId;
    else
        id=0;
    end

end