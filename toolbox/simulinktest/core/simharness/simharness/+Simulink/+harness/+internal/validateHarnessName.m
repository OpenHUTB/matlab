function validateHarnessName(model,~,harnessName)

    if~isvarname(harnessName)
        DAStudio.error('Simulink:Harness:HarnessNameNotValid',...
        harnessName);
    end

    if length(harnessName)>58
        DAStudio.error('Simulink:Harness:NameTooLong',harnessName);
    end

    hList=Simulink.harness.internal.getHarnessList(model,'all');
    availableHarnessNames={hList.name};


    [~,ind]=ismember(harnessName,availableHarnessNames);
    if ind~=0
        DAStudio.error('Simulink:Harness:HarnessNameMustBeUniqueForAModel');
    end


    deletedHarnessNames=Simulink.harness.internal.getDeletedHarnessNames(model);
    [~,ind]=ismember(harnessName,deletedHarnessNames);
    if ind~=0
        DAStudio.error('Simulink:Harness:CannotUseDeletedHarnessName',harnessName);
    end



    inMemoryModels=lower(find_system('type','block_diagram'));
    [~,ind]=ismember(lower(harnessName),inMemoryModels);
    if ind~=0
        DAStudio.error('Simulink:Harness:HarnessNameInUse',harnessName);
    end


    if~isempty(which(harnessName))
        Simulink.harness.internal.warn({'Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD',harnessName});
    end
