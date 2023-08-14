function execute(this)



    try
        this.performProposal();
    catch proposalError
        rethrow(proposalError);
    end
end