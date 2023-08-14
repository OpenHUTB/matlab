function AttachCopyOfConfigSetRef(harnessInfo)


    harnessName=get_param(harnessInfo.HarnessModel,'Name');

    activeConfigSet=getActiveConfigSet(harnessName);
    RefName=get_param(activeConfigSet,'Name');


    if(isa(activeConfigSet,'Simulink.ConfigSetRef'))
        copyOfRef=activeConfigSet.getRefConfigSet;

        attachConfigSetCopy(harnessName,copyOfRef);

        configName=get_param(copyOfRef,'Name');
        setActiveConfigSet(harnessName,configName);

        detachConfigSet(harnessName,RefName);
    end
end