function[subModel,topModel,subs]=validateSupportedSpecsForSubsystem(subsys,topModelName,recordCurrentState,createForTopModel)



    subsys=string(subsys);
    topModelName=string(topModelName);

    if~contains(subsys,"/")&&~createForTopModel
        subsys=topModelName+"/"+subsys;
    end

    load_system(topModelName);


    subsysH=get_param(subsys,'handle');


    simMode=get_param(topModelName,'SimulationMode');
    if~strcmp(simMode,'normal')&&~strcmp(simMode,'accelerator')
        error(message('stm:general:TestForSubsystemInvalidSimulationMode'));
    end


    if isinf(str2double(get_param(topModelName,'StopTime')))
        error(message('stm:general:InvalidSimulationStopTime'));
    end


    [subModel,topModel]=stm.internal.TestForSubsystem.getSubsystemInfo(subsys,topModelName);
    stm.internal.TestForSubsystem.validateSupportedSpecsForSubsystemHelper(subModel,createForTopModel,recordCurrentState,subsysH,topModel);
    subs=get_param(subsys,"Object");
end




