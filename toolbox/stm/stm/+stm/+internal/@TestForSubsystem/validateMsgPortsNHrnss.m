function validateMsgPortsNHrnss(tForSubsys,isLoggingWorkflow)




    subsys=tForSubsys.subsys;
    topModel=tForSubsys.topModel;
    subModel=tForSubsys.subModel;
    numOfComps=tForSubsys.numOfComps;
    for i=1:numOfComps
        try
            stm.internal.TestForSubsystem.validateSupportedSpecsForSubsystemHelper(...
            subModel(i),tForSubsys.createForTopModel,...
            isLoggingWorkflow,get_param(subsys(i),"Handle"),topModel);
        catch me
            tForSubsys.populateErrorContainer(me,i);
        end
    end
end

