

function makeBlockSizeElegant(blockPath)



    [portCount,portNameAlphabetCount]=getMFBPortInfo(blockPath);
    mfbPosition=get_param(blockPath,'Position');

    newPosition=mfbPosition;


    defaultWidth=100;
    singleAlphabetWidth=8;
    blockWidthPadding=110;
    if portNameAlphabetCount~=0
        newPosition(3)=newPosition(1)+blockWidthPadding+singleAlphabetWidth*portNameAlphabetCount;
    else
        newPosition(3)=newPosition(1)+defaultWidth;
    end


    defaultHeight=100;
    singlePortHeight=40;
    blockHeightPadding=60;
    if portCount~=0
        newPosition(4)=newPosition(2)+blockHeightPadding+singlePortHeight*portCount;
    else
        newPosition(4)=newPosition(2)+defaultHeight;
        set_param(blockPath,'Position',newPosition);
    end

    set_param(blockPath,'Position',newPosition);
end






function[portCount,portNameAlphabetCount]=getMFBPortInfo(blockPath)

    h_Inports=plc_find_system(blockPath,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Inport');
    inputs=get_param(h_Inports,'Name');
    h_Outports=plc_find_system(blockPath,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Outport');
    outputs=get_param(h_Outports,'Name');

    if ischar(inputs)
        inputs={inputs};
    end

    if ischar(outputs)
        outputs={outputs};
    end

    inputPortCount=length(inputs);
    outputPortCount=length(outputs);

    if inputPortCount>outputPortCount
        portCount=inputPortCount;
    else
        portCount=outputPortCount;
    end

    maxInputPortNameLength=0;
    for ii=1:inputPortCount
        nameLength=length(inputs{ii});

        if nameLength>maxInputPortNameLength
            maxInputPortNameLength=nameLength;
        end
    end

    maxOutputPortNameLength=0;
    for ii=1:outputPortCount
        nameLength=length(outputs{ii});

        if nameLength>maxOutputPortNameLength
            maxOutputPortNameLength=nameLength;
        end
    end

    portNameAlphabetCount=maxInputPortNameLength+maxOutputPortNameLength;
end


