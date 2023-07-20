function entries=doConfigParams(model,cbType,legacyConfigParams)








    if~strcmp(cbType,'check')&&~strcmp(cbType,'upgrade')
        error("Incorrect Usage");
    end

    entries={};


    tlcOpt=get_param(model,'TLCOptions');
    tlcOpt=tlcOpt(tlcOpt~=' ');

    depOverloadOptions={};
    if contains(tlcOpt,'-axPCMaxOverloads')
        depOverloadOptions=[depOverloadOptions,'-axPCMaxOverloads'];
    end
    if contains(tlcOpt,'-axPCOverLoadLen')
        depOverloadOptions=[depOverloadOptions,'-axPCOverLoadLen'];
    end
    if contains(tlcOpt,'-axPCStartupFlag')
        depOverloadOptions=[depOverloadOptions,'-axPCStartupFlag'];
    end
    if~isempty(depOverloadOptions)
        depOverloadOptions=strjoin(depOverloadOptions,', ');
        switch cbType
        case 'check'
            entries{end+1}={DAStudio.message('slrealtime:advisor:tlcOptions'),DAStudio.message('slrealtime:advisor:deprecatedOverloadOptions',depOverloadOptions)};
        case 'upgrade'
            entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:overloadOptionsNotUpgraded'));
            entry.setColor('Warn');
            entries{end+1}=entry;
        end
    end

    [pollStr,pollVal]=get_xpcCPUClockPoll(model);
    if~isempty(pollStr)
        switch cbType
        case 'check'
            entries{end+1}={DAStudio.message('slrealtime:advisor:tlcOptions'),DAStudio.message('slrealtime:advisor:pollingMode')};
        case 'upgrade'
            if pollVal==0
                forcePoll='off';
            else
                forcePoll='on';
            end
            set_param(model,'SLRTForcePollingMode',forcePoll);
            remove_xpcCPUClockPoll(model);
            entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:pollingModeUpgraded',pollStr,forcePoll));
            entry.setColor('Pass');
            entries{end+1}=entry;
        end
    end


    if~isempty(legacyConfigParams)


        execMode=legacyConfigParams('RL32ModeModifier');
        interruptSource=legacyConfigParams('RL32IRQSourceModifier');
        ioBoard=legacyConfigParams('xPCIRQSourceBoard');
        pciSlot=legacyConfigParams('xPCIOIRQSlot');
        nonDefault={};
        if~strcmpi(execMode,'Real-Time')
            nonDefault=[nonDefault,['RL32ModeModifier=''',execMode,'''']];
        end
        if~strcmpi(interruptSource,'Timer')
            nonDefault=[nonDefault,['RL32IRQSourceModifier=''',interruptSource,'''']];
        end
        if~strcmpi(ioBoard,'None/Other')
            nonDefault=[nonDefault,['xPCIRQSourceBoard=''',ioBoard,'''']];
        end
        if~strcmpi(pciSlot,'-1')
            nonDefault=[nonDefault,['xPCIOIRQSlot=''',pciSlot,'''']];
        end
        if~isempty(nonDefault)
            nonDefault=strjoin(nonDefault,', ');
            switch cbType
            case 'check'
                entries{end+1}={DAStudio.message('slrealtime:advisor:execOptions'),DAStudio.message('slrealtime:advisor:deprecatedExecOptions',nonDefault)};
            case 'upgrade'
                entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:execOptionsNotUpgraded',nonDefault));
                entry.setColor('Warn');
                entries{end+1}=entry;
            end
        end

        if strcmpi(legacyConfigParams('RL32LogTETModifier'),'on')
            switch cbType
            case 'check'
                entries{end+1}={DAStudio.message('slrealtime:advisor:tetMonitoring'),DAStudio.message('slrealtime:advisor:deprecatedTETMonitor')};
            case 'upgrade'
                entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:tetNotUpgraded'));
                entry.setColor('Warn');
                entries{end+1}=entry;
            end
        end

        if strcmpi(legacyConfigParams('xPCLoadParamSetFile'),'on')
            switch cbType
            case 'check'
                entries{end+1}={DAStudio.message('slrealtime:advisor:paramSet'),DAStudio.message('slrealtime:advisor:loadParamSetNotSupported')};
            case 'upgrade'
                entry=ModelAdvisor.Text(DAStudio.message('slrealtime:advisor:loadParamSetNotSupported'));
                entry.setColor('Warn');
                entries{end+1}=entry;
            end
        end
    end



end

function[xpcCPUClockPollStr,pollVal]=get_xpcCPUClockPoll(model)
    tlcOpt=split(get_param(model,'TLCOptions'));
    xpcCPUClockPollStr='';
    pollVal=0;
    for i=1:length(tlcOpt)
        if strfind(tlcOpt{i},'-axpcCPUClockPoll=')
            tlcOpt{i}=tlcOpt{i}(tlcOpt{i}~=' ');
            pollVal=str2double(extractAfter(tlcOpt{i},'-axpcCPUClockPoll='));
            if~isnan(pollVal)

                xpcCPUClockPollStr=tlcOpt{i};
                break;
            end
        end
    end
end

function remove_xpcCPUClockPoll(model)
    xpcCPUClockPoll=get_xpcCPUClockPoll(model);
    tlcOpt=get_param(model,'TLCOptions');
    tlcOpt=erase(tlcOpt,xpcCPUClockPoll);
    set_param(model,'TLCOptions',tlcOpt);
end