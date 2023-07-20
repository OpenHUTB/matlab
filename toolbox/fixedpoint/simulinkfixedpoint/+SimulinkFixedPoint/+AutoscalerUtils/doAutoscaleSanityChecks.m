function doAutoscaleSanityChecks(bd,cmd)





    if~strcmpi(cmd,'Collect')&&~strcmpi(cmd,'Propose')&&~strcmpi(cmd,'Apply')
        DAStudio.error('SimulinkFixedPoint:autoscaling:commandNotFound');
    end



    if~isa(bd,'Simulink.BlockDiagram')&&~isa(bd,'Simulink.SubSystem')
        DAStudio.error('SimulinkFixedPoint:autoscaling:topSubsysNotValid');
    end
end

