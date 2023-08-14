function reportedResults=performProposal(this,groups)














    resultsCell=cellfun(@(x)(x.getGroupMembers),groups,'UniformOutput',false);


    allResults=[resultsCell{:}];




    reportedResults=[];

    if~isempty(allResults)


        resultsScope=SimulinkFixedPoint.AutoscalerUtils.getResultsScopeMap(allResults,this.SelectedSystem);


        DataTypeWorkflow.Single.Utils.getGroupsProposal(resultsScope,groups);


        resultsToReportIndex=cellfun(@(x)(~isempty(x.getProposedDT)&&~strcmp(x.getProposedDT,'n/a')),allResults);


        reportedResults=allResults(resultsToReportIndex);
    end
end


