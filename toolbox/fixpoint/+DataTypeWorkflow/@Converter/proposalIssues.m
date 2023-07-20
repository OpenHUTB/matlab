function out=proposalIssues(this,runName)













    this.assertDEValid();
    try
        out=this.results(runName,@(r)any(strcmp(r.ProposedDataType,{'n/a',getString(message('FixedPointTool:fixedPointTool:Locked'))})));
    catch e
        throw(e);
    end
end