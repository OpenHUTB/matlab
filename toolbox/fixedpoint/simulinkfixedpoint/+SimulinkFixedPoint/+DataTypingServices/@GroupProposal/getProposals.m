function getProposals(this,runObj)









    allGroups=runObj.dataTypeGroupInterface.getGroups();


    for groupIndex=1:length(allGroups)
        group=allGroups{groupIndex};


        if this.proposalSettings.isWLSelectionPolicy


            effectiveConstraint=group.constraints+this.hardwareConstraint;


















        else
            effectiveConstraint=group.constraints;
        end

        proposedDataType=...
        this.getProposalForGroup(...
        group,...
        group.getSpecifiedDataType(this.proposalSettings),...
        group.getRangeForProposal(this.proposalSettings).getExtrema(),...
        effectiveConstraint);

        if~isempty(proposedDataType)

            group.setFinalProposedDataType(proposedDataType,this.resultsScope,this.proposalSettings);
        end
    end
end

