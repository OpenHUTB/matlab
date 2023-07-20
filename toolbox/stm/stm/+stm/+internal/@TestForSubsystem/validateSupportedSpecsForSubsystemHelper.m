function validateSupportedSpecsForSubsystemHelper(subModel,~,recordCurrentState,subsysH,topModel)




    rootBD=Simulink.harness.internal.getHarnessOwnerBD(subModel.char);
    if~isempty(rootBD)

        error(message('stm:general:BaselineFromSubsystemNotSupportedForHarness'));
    end

    topModelH=get_param(topModel,"Handle");

    if get_param(subsysH,"Type")~="block_diagram"&&recordCurrentState&&isWithInEnableTrigFuncCallSubsys(subsysH)
        error(message('stm:general:TestForSubsystemNotAllowedForSubsystemWithinControlPortSubsys'));
    end

    if subsysH==topModelH&&bdIsLibrary(topModel)
        error(message('stm:TestForSubsystem:TestForLibraryMdlNotSupported'));
    end


    activeHarness=Simulink.harness.internal.getActiveHarness(subModel.char);
    if~isempty(activeHarness)

        if strcmp(activeHarness.type,'CodeContext')
            close_system(activeHarness.name);
        else

            Simulink.harness.close(activeHarness.ownerFullPath,activeHarness.name);
        end
    end
end

function result=isWithInEnableTrigFuncCallSubsys(blockH)
    result=false;
    modelH=bdroot(blockH);
    blockH=get_param(get_param(blockH,'Parent'),'Handle');
    while blockH~=modelH
        ssType=Simulink.SubsystemType(blockH);
        if ssType.isEnabledSubsystem...
            ||ssType.isEnabledAndTriggeredSubsystem...
            ||ssType.isTriggeredSubsystem...
            ||ssType.isFunctionCallSubsystem...
            ||ssType.isIteratorSubsystem
            result=true;
            return;
        end
        blockH=get_param(get_param(blockH,'Parent'),'Handle');
    end
end
