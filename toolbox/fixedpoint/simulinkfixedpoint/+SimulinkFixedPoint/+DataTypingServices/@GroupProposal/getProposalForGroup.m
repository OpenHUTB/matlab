function proposedDataType=getProposalForGroup(this,group,groupSpecifiedDataType,groupRange,effectiveConstraint)









    groupMembers=group.getGroupMembers();


    [isProposable,comment]=this.groupProposalCheckStrategy.isGroupProposable(...
    effectiveConstraint,...
    groupSpecifiedDataType,...
    groupRange,...
    group);

    if~isProposable


        cellfun(@(x)(x.setProposedDT('n/a')),groupMembers);
        proposedDataType=Simulink.NumericType.empty;
    else
        proposedDataType=groupSpecifiedDataType.evaluatedNumericType;
        if groupSpecifiedDataType.isFixed
            proposedDataType.DataTypeOverride=groupSpecifiedDataType.evaluatedNumericType.DataTypeOverride;
        end


        if any(groupRange)

            dataTypeSelector=SimulinkFixedPoint.AutoscalerUtils.getDataTypeSelector(this.proposalSettings);



            proposedDataType=dataTypeSelector.propose(groupRange,proposedDataType);
        end


        if isa(effectiveConstraint,'SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint')
            proposedDataType=snapDataType(effectiveConstraint,proposedDataType);
        end
    end


    if~isempty(comment)
        cellfun(@(x)(x.addComment(comment)),groupMembers);
    end
end