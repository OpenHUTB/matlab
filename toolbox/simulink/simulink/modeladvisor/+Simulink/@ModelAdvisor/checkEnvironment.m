function checkEnvironment(subsys)
    subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
    model=bdroot(subsys(1));

    if modeladvisorprivate('modeladvisorutil2','InsideInactiveVariantBlock',subsys)
        DAStudio.error('ModelAdvisor:engine:InactiveVariantSystem');
    end

    if strcmp(get_param(model,'SimulationStatus'),'compiled')
        DAStudio.error('ModelAdvisor:engine:InitializedSystemNotSupported');
    end

    if slInternal('isSubsystem',subsys)
        commentedPrm=get_param(subsys,'Commented');
        if any(strcmp(commentedPrm,{'through','on'}))
            DAStudio.error('ModelAdvisor:engine:CommentedSystemNotSupported');
        end
    end

    if strcmp(get_param(model,'SimulationStatus'),'running')
        DAStudio.error('ModelAdvisor:engine:RunChecksWhileInSimulationNotSupported');
    end
end
