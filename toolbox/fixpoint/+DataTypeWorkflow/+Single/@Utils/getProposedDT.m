function getProposedDT(result,resultsScope,proposedDT)












    specialHandlingDT=DataTypeWorkflow.Single.Utils.specialHandlingForResults(result,resultsScope);

    if isempty(specialHandlingDT)
        result.ProposedDT=proposedDT;
        result.updateAcceptFlag;
    else
        result.ProposedDT=specialHandlingDT;
    end

end