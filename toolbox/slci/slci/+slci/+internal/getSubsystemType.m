


function Type=getSubsystemType(sys)

    ssType=Simulink.SubsystemType(sys.Handle);
    if ssType.isMessageTriggeredFunction





        Type='MessageTrigger';
    elseif ssType.isSimulinkFunction
        Type='SimulinkFunction';
    elseif ssType.isFunctionCallSubsystem
        Type='Function-call';
    elseif ssType.isEnabledAndTriggeredSubsystem
        Type='EnableTrigger';
    elseif ssType.isEnabledSubsystem
        Type='Enable';
    elseif ssType.isTriggeredSubsystem
        Type='Trigger';
    elseif ssType.isVariantSubsystem
        Type='Variant';
    elseif ssType.isActionSubsystem
        Type='Action';
    elseif ssType.isStateflowSubsystem
        Type='Stateflow';
    elseif ssType.isForIteratorSubsystem
        Type='For';
    elseif ssType.isWhileIteratorSubsystem
        Type='While';
    elseif ssType.isForEachSubsystem
        Type='ForEach';
    elseif ssType.isIteratorSubsystem
        Type='Iterator';
    elseif ssType.isAtomicSubsystem
        Type='Atomic';
    elseif ssType.isVirtualSubsystem
        Type='Virtual';
    elseif ssType.isPhysmodSubsystem
        Type='Physmod';
    else
        Type='Subsystem';
    end
end
