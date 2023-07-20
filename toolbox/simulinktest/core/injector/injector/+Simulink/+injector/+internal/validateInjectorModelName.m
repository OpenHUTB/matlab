function validateInjectorModelName(contextModelName)


    if~isvarname(contextModelName)
        DAStudio.error('Simulink:Injector:InjectorNameNotValid',...
        contextModelName);
    end


    if length(contextModelName)>58
        DAStudio.error('Simulink:Injector:NameTooLong',contextModelName);
    end


    inMemoryModels=lower(find_system('type','block_diagram'));
    [~,ind]=ismember(lower(contextModelName),inMemoryModels);
    if ind~=0
        DAStudio.error('Simulink:Injector:InjectorNameInUse',contextModelName);
    end


    if~isempty(which(contextModelName))
        Simulink.harness.internal.warn({'Simulink:Injector:WarnAboutNameShadowingOnCreationfromCMD',contextModelName});
    end