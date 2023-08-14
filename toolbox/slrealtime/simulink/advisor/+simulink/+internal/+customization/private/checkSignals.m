function sigUpgTable=checkSignals(model)




    sigUpgTable=ModelAdvisor.FormatTemplate('TableTemplate');
    sigUpgTable.setSubTitle(DAStudio.message('slrealtime:advisor:signalsSubTitle'));
    sigUpgTable.setColTitles({DAStudio.message('slrealtime:advisor:signalName'),DAStudio.message('slrealtime:advisor:action')});

    bufferedSigs=slrealtime.internal.logging.UpgradeUtils.getBufferedSignals(model);
    if isempty(bufferedSigs)
        sigUpgTable.setSubResultStatus('Pass');
        sigUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:noSignalsToUpgrade'));
    else
        sigUpgTable.setSubResultStatus('Warn');
        sigUpgTable.setSubResultStatusText(DAStudio.message('slrealtime:advisor:foundBufferedSig'));
        sigList=ModelAdvisor.List;
        for i=1:length(bufferedSigs)
            srcBlk=bufferedSigs(i).getAlignedBlockPath;
            slh=get_param(srcBlk,'LineHandles');
            lineh=slh.Outport(bufferedSigs(i).OutputPortIndex);
            sigList.addItem(Simulink.ID.getFullName(lineh));
            linehstr=sprintf('%18.16f',lineh);
            sigList.Items{i}.setHyperlink(['matlab: modeladvisorprivate hiliteLine ',num2str(linehstr)]);
        end
        sigUpgTable.addRow({sigList,DAStudio.message('slrealtime:advisor:unbadgeInsertFileLog')});
    end



