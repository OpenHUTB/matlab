function ApplySignals(hBlk,signals,outputSignal,sigNames)







    signals=strtrim(signals);

    blkHandle=get_param(hBlk,'object');
    fullSubsystemBlockName=blkHandle.getFullName;
    multiportSwitchName=[fullSubsystemBlockName,'/MultiportSwitch'];



    derivedSignals.util.ClearSignals(hBlk);


    rowCount=0;

    blockNames={};

    for i=1:length(signals)

        set_param(multiportSwitchName,'Inputs',num2str(rowCount+1));


        signalName='';
        if(nargin>3)
            signalName=char(sigNames{i,1});
        else
            uuid=['_',strrep(char(matlab.lang.internal.uuid()),'-','')];
            uuid=uuid(1:16);
            signalName=['MultiportSwitch',uuid];
        end

        blockNames{i,1}=signalName;


        newSignalBlockName=[fullSubsystemBlockName,'/',signalName];
        newBlockPosition=get_param(multiportSwitchName,'Position');
        newBlockPosition(1)=newBlockPosition(1)-250;
        newBlockPosition(2)=newBlockPosition(2)+(rowCount*75);
        newBlockPosition(3)=newBlockPosition(1)+50;
        newBlockPosition(4)=newBlockPosition(2)+50;

        expressionStr=char(signals{i,1});
        if strcmp('',strtrim(expressionStr))
            add_block('built-in/Ground',newSignalBlockName,'Position',newBlockPosition,'DisableCoverage','on');
        else
            add_block('built-in/DerivedSignal',newSignalBlockName,'Position',...
            newBlockPosition,'Expression',expressionStr,'SampleTime','SampleTime','DisableCoverage','on');
        end


        outputPorts=get_param(newSignalBlockName,'PortHandles');
        inputPorts=get_param(multiportSwitchName,'PortHandles');
        add_line(fullSubsystemBlockName,outputPorts.Outport,inputPorts.Inport(rowCount+2));
        rowCount=rowCount+1;
    end
    blkHandle.Signals=strjoin(signals,'#');
    blkHandle.BlockNames=strjoin(blockNames,'#');
    blkHandle.SelectedSignal=num2str(outputSignal);
end

