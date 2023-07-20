function abortIfNoRemainingCUT(obj)




    if~any(obj.proceedToNextStep)







        assert(obj.isInBatchMode);
        eID='stm:TestForSubsystem:TestCreationFailedForAllComponents';
        baseMex=MException(eID,message(eID).getString);
        throwAsCaller(baseMex);
    end
end


