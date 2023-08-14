function[dataTypeSelector,baseTypeForProposal]=getDataTypeSelectorWithConstraints(constraint,baseTypeForProposal,proposalSettings)









    dataTypeSelector=SimulinkFixedPoint.AutoscalerUtils.getDataTypeSelector(proposalSettings);

    if~isempty(constraint)

        [baseTypeForProposal,dataTypeSelector]=...
        SimulinkFixedPoint.AutoscalerUtils.refineDTBasedOnConstraints(...
        baseTypeForProposal,...
        dataTypeSelector,...
        constraint,...
        proposalSettings);
    end
end