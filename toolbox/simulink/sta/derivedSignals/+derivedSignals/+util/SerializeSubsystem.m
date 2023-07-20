function output=SerializeSubsystem(hBlk)





    blkHandle=get_param(hBlk,'Object');
    fullSubsystemBlockName=blkHandle.getFullName;
    multiportSwitchName=[fullSubsystemBlockName,'/MultiportSwitch'];
    numRows=str2double(get_param(multiportSwitchName,'Inputs'));
    inputConnections=get_param(multiportSwitchName,'PortConnectivity');

    signals=cell(numRows,1);


    for i=(numRows):-1:1
        inputConnection=inputConnections(i+1);

        if(inputConnection.SrcBlock>0)
            srcBlk=get_param(inputConnection.SrcBlock,'Object');
            if(strcmp(srcBlk.BlockType,'DerivedSignal'))
                signals{i,1}=srcBlk.Expression;
            elseif(strcmp(srcBlk.BlockType,'Ground'))
                signals{i,1}='';
            else

            end
        end
    end
    output=strjoin(signals,'#');
end

