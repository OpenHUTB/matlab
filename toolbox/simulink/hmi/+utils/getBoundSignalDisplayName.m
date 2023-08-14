

function[displayName,localPath]=getBoundSignalDisplayName(boundElem,varargin)

    maxLength=0;
    if nargin>=2
        maxLength=varargin{1};

        assert(maxLength>3);
    end
    displayName='';
    localPath=boundElem.BlockPath.getBlock(boundElem.BlockPath.getLength);
    portHandles=get_param(localPath,'PortHandles');
    if boundElem.OutputPortIndex>0&&...
        boundElem.OutputPortIndex<=length(portHandles.Outport)


        displayName=get_param(portHandles.Outport(boundElem.OutputPortIndex),'Name');
    elseif Simulink.HMI.SignalSpecification.isSFSignal(boundElem)


        displayName=boundElem.SignalName_;
    end
    if~isempty(displayName)

        if maxLength>0&&length(displayName)>maxLength
            displayName=[extractBefore(displayName,maxLength-3),'...'];
        end
    else


        blockName=get_param(localPath,'Name');
        portIndex=num2str(boundElem.OutputPortIndex);
        if maxLength>0
            maxLength=maxLength-length(portIndex)-1;
            if length(blockName)>maxLength
                blockName=[extractBefore(blockName,maxLength-3),'...'];
            end
        end
        displayName=[blockName,':',portIndex];
    end
end