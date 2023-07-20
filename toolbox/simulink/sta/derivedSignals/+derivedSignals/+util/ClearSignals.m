function ClearSignals(hBlk)





    blkHandle=get_param(hBlk,'Object');
    fullSubsystemBlockName=blkHandle.getFullName;
    multiportSwitchName=[fullSubsystemBlockName,'/MultiportSwitch'];

    ports=get_param(multiportSwitchName,'PortHandles');
    rowCount=str2double(get_param(multiportSwitchName,'Inputs'));

    for i=0:(rowCount-1)
        line=get_param(ports.Inport(i+2),'Line');
        block2delete=get_param(line,'SrcBlockHandle');
        delete(line);
        delete(block2delete);
    end


    set_param(fullSubsystemBlockName,'SelectedSignal','1');

    set_param(multiportSwitchName,'Inputs','1');
end

