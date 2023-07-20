function[harnessModelName,objectSID]=getHarnessObjectFromUniqueID(uniqueId,shouldOpen)
    harnessModelName='';
    objectSID='';

    idStrs=regexp(uniqueId,':','split');
    systemModel=idStrs{1};

    uuid=[idStrs{2},':',idStrs{3},':',idStrs{4}];

    harnessInfo=Simulink.harness.find(systemModel,'uuid',uuid);

    if~isempty(harnessInfo)
        if nargin>1&&shouldOpen
            activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);
            if~isempty(activeHarness)&&~strcmp(harnessInfo.name,activeHarness.name)
                Simulink.harness.close(activeHarness.ownerFullPath,activeHarness.name);
            end
            if harnessInfo.isOpen
                open_system(harnessInfo.name);
            else
                Simulink.harness.open(harnessInfo.ownerFullPath,harnessInfo.name);
            end
        end
        harnessModelName=harnessInfo.name;
        objectSID=strrep(uniqueId,[systemModel,':',uuid],'');
    end

end
