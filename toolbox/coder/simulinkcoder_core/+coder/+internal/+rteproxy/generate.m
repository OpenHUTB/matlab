




function generate(model,sdpTypes,usingTimerService)


    if~usingTimerService
        return;
    end

    assert(sdpTypes.PlatformType==coder.internal.rte.PlatformType.Function||...
    sdpTypes.PlatformType==coder.internal.rte.PlatformType.ApplicationWithServices);



    switch sdpTypes.DeploymentType
    case coder.internal.rte.DeploymentType.Component

        fileGenerator=coder.internal.rteproxy.SubassemblySourceFileGenerator(model);
        fileGenerator.build;
    case coder.internal.rte.DeploymentType.Subcomponent

        fileGenerator=coder.internal.rteproxy.SubassemblyHeaderFileGenerator(model);
        fileGenerator.build;
    otherwise
        assert(false,'Unexpected Deployment Type encountered.');
    end

end
