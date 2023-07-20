function harnessStruct=validateHarnessNameForOwner(systemModel,harnessOwnerHandle,harnessName)




    harnessList=Simulink.harness.internal.getHarnessList(systemModel,'all',harnessOwnerHandle);

    if isempty(harnessList)

        DAStudio.error('Simulink:Harness:NoHarnessExist');
    end

    compareUUID=false;
    if strncmp(harnessName,'urn:uuid:',9)
        compareUUID=true;
    end


    if~compareUUID
        availableHarnessNames={harnessList.name};
        [~,ind]=ismember(harnessName,availableHarnessNames);
    else
        availableHarnessUUIDs={harnessList.uuid};
        [~,ind]=ismember(harnessName,availableHarnessUUIDs);
    end

    if ind==0

        blockName=get_param(harnessOwnerHandle,'Name');
        blockName=strrep(blockName,'\n',' ');
        DAStudio.error('Simulink:Harness:NoHarnessFound',blockName,harnessName);
    else
        harnessStruct=harnessList(ind);
    end
