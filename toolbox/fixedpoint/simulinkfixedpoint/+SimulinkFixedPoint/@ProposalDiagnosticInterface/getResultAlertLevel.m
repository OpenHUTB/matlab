function alertLevel=getResultAlertLevel(this,result,group)















    alertLevel=this.resultDiagnostic.getAlertLevel(result,[],this.proposalSettings);

    if~isempty(group)




        if group.members.Count>1


            groupedResultAlertLevel=this.groupedResultDiagnostic.getAlertLevel(result,group,this.proposalSettings);



            alertLevel=SimulinkFixedPoint.ProposalDiagnostics.AlertLevelsEnum.max([alertLevel,groupedResultAlertLevel]);
        end
    end
end