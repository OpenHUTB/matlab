function info=getBlockInfo(this,slbh)


    info=struct;

    info.BlockHandle=slbh;
    if isa(this,'hdldefaults.ResetPort')
        info.StatesWhenEnabling='';
        info.SLOutputPorts='';
    else

        info.StatesWhenEnabling=get_param(slbh,'StatesWhenEnabling');
        info.SLOutputPorts=get_param(slbh,'ShowOutputPort');
    end




    parent=get_param(slbh,'Parent');
    inPorts=find_system(parent,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1,'BlockType','Inport');
    outPorts=find_system(parent,'FollowLinks','on','LookUnderMasks','all',...
    'SearchDepth',1,'BlockType','Outport');


    info.InputBlocks=repmat(struct,length(inPorts),1);
    info.OutputBlocks=repmat(struct,length(outPorts),1);

    for i=1:length(inPorts)
        info.InputBlocks(i).LatchByDelayingOutsideSignal=uncellify(get_param(inPorts(i),...
        'LatchByDelayingOutsideSignal'));
        info.InputBlocks(i).Name=uncellify(get_param(inPorts(i),'Name'));
    end
    for i=1:length(outPorts)
        info.OutputBlocks(i).OutputWhenDisabled=uncellify(get_param(outPorts(i),...
        'OutputWhenDisabled'));
        info.OutputBlocks(i).InitialOutput=uncellify(get_param(outPorts(i),...
        'InitialOutput'));
        info.OutputBlocks(i).Name=uncellify(get_param(outPorts(i),'Name'));
    end
end

function result=uncellify(whatever)
    if iscell(whatever)&&length(whatever)==1
        result=whatever{1};
    else
        result=whatever;
    end
end
