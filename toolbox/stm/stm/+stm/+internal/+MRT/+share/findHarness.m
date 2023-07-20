function harnessStructArr=findHarness(model)


    modelCloseObj=Simulink.SimulationData.ModelCloseUtil(true);
    ocd=onCleanup(@()delete(modelCloseObj));

    if isempty(model)
        stm.internal.MRT.share.error('stm:general:NoModelSelected');
    end


    load_system(model);

    harnesses=Simulink.harness.find(model);
    if isempty(harnesses)
        harnessStructArr=[];
        return;
    end

    harnessStructArr=struct(...
    'Name',{harnesses.name},...
    'OwnerPath',{harnesses.ownerFullPath},...
    'OrigSrc',{harnesses.origSrc},...
    'SaveExternally',false,...
    'OwnerType','',...
    'SynchronizationMode',1,...
    'ChecksumMatched',true);

    fieldNames=fieldnames(harnesses);
    nameMap=containers.Map;
    for k=1:length(fieldNames)
        nameMap(fieldNames{k})=1;
    end
    for x=1:length(harnesses)
        if(isKey(nameMap,'saveExternally'))
            harnessStructArr(x).SaveExternally=harnesses(x).saveExternally;
        end
        if(isKey(nameMap,'ownerType'))
            harnessStructArr(x).OwnerType=harnesses(x).ownerType;
        end
        if(isKey(nameMap,'synchronizationMode'))
            harnessStructArr(x).SynchronizationMode=harnesses(x).synchronizationMode;
        end
    end
end

