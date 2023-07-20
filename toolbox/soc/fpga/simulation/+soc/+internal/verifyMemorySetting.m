function verifyMemorySetting(blkH)




    l_errorIfMemoryChannelBlk(blkH);
    l_errorIfMemoryControllerBlk(blkH);
    l_errorIfConcurrencySettingInvalid(blkH);

end

function l_errorIfMemoryChannelBlk(blkH)

    sysH=bdroot(blkH);
    memChBlkVec=find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Channel');
    if any(memChBlkVec)
        blkName=get_param(blkH,'Name');
        memChNameVec=get_param(memChBlkVec,'Name');
        error(message('soc:msgs:NotCompatibleWithMemoryChannel',blkName,strjoin(memChNameVec,''', ''')));
    end

end

function l_errorIfMemoryControllerBlk(blkH)

    sysH=bdroot(blkH);
    memCtrlBlkVec=find_system(sysH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','socmemlib/Memory Controller');
    if any(memCtrlBlkVec)
        blkName=get_param(blkH,'Name');
        memCtrlNameVec=get_param(memCtrlBlkVec,'Name');
        error(message('soc:msgs:NotCompatibleWithMemoryController',blkName,strjoin(memCtrlNameVec,''', ''')));
    end

end

function l_errorIfConcurrencySettingInvalid(blkH)

    sysH=bdroot(blkH);

    if strcmpi(get_param(blkH,"MemorySimulation"),'Behavioral')&&...
        strcmpi(get_param(sysH,"ConcurrentTasks"),'on')

        blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
        mdlName=get_param(sysH,'Name');

        error(message('soc:msgs:ConcurrentTaskMustBeOff',blkPath,mdlName));
    end

end
