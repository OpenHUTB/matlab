classdef GroupProposal<SimulinkFixedPoint.DataTypingServices.AbstractAction


















    properties(Access=protected)
resultsScope
groupProposalCheckStrategy
    end

    properties(SetAccess=protected)
        hardwareConstraint=SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint.empty;
    end

    methods(Access=public)
        function this=GroupProposal(sysToScaleName,refMdls,proposalSettings)
            this.sysToScaleName=sysToScaleName;
            this.refMdls=refMdls;
            this.proposalSettings=proposalSettings;
            this.hardwareConstraint=SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(this.sysToScaleName);
            this.groupProposalCheckStrategy=SimulinkFixedPoint.DataTypingServices.GroupProposalCheck.FixedPointStrategy();
        end

        execute(this)
    end

    methods(Access=public,Hidden)
        proposedDataType=getProposalForGroup(this,groupMembers,groupSpecifiedDataType,groupRange,effectiveConstraint)
        getProposals(this,allGroups)
        performProposal(this)
        determineWarnings(this,runObj)
    end
end
