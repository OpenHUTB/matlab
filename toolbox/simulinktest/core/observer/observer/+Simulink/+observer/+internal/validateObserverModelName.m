function validateObserverModelName(contextModelName)

    if~isvarname(contextModelName)
        DAStudio.error('Simulink:Observer:ObserverNameNotValid',...
        contextModelName);
    end

    if length(contextModelName)>58
        DAStudio.error('Simulink:Observer:NameTooLong',contextModelName);
    end
    inMemoryModels=lower(find_system('type','block_diagram'));
    [~,ind]=ismember(lower(contextModelName),inMemoryModels);
    if ind~=0
        DAStudio.error('Simulink:Observer:ObserverNameInUse',contextModelName);
    end

    if~isempty(which(contextModelName))
        Simulink.harness.internal.warn({'Simulink:Observer:WarnAboutNameShadowingOnCreationfromCMD',contextModelName});
    end