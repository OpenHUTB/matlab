function diagnostics=getResultDiagnostics(this,result,group)
















    diagnostics=this.resultDiagnostic.getDiagnostics(result,[],this.proposalSettings);



    if~isempty(group)




        if group.members.Count>1


            groupedResultDiagnostics=this.groupedResultDiagnostic.getDiagnostics(result,group,this.proposalSettings);
            diagnostics=[diagnostics,groupedResultDiagnostics];
        end
    end
end