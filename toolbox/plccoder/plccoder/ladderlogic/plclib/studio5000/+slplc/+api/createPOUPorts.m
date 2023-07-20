function createPOUPorts(block,varList)

    for dataCount=1:numel(varList)
        varInfo=varList(dataCount);
        if strcmpi(varInfo.PortType,'inport')
            inportName=getPortName(varInfo,'inport');
            inportFullName=[block,'/',inportName];
            safe_add_block('built-in/Inport',inportFullName);
            set_param(inportFullName,'Port',varInfo.PortIndex);
        elseif strcmpi(varInfo.PortType,'outport')
            outportName=getPortName(varInfo,'outport');
            outportFullName=[block,'/',outportName];
            safe_add_block('built-in/Outport',outportFullName);
            set_param(outportFullName,'Port',varInfo.PortIndex);
        elseif strcmpi(varInfo.PortType,'inport/outport')
            varInfo.PortType='inport';
            slplc.api.createPOUPorts(block,varInfo);
            varInfo.PortType='outport';
            slplc.api.createPOUPorts(block,varInfo);
        end

    end

end

function portName=getPortName(varInfo,portType)
    if isempty(varInfo.Address)||strcmpi(varInfo.Address,'<empty>')
        portName=varInfo.Name;
    else
        portName=[varInfo.Name,' At ',varInfo.Address];
    end
    if strcmpi(varInfo.Scope,'inout')&&strcmpi(portType,'Outport')
        portName=[' ',portName];
    end

    if strcmpi(portName,'EnableIn')
        portName='RungIn';
    elseif strcmpi(portName,'EnableOut')
        portName='RungOut';
    end

end

function blkH=safe_add_block(src,dst,varargin)
    blkH=-1;
    if getSimulinkBlockHandle(dst)<=0

        blkH=add_block(src,dst,varargin{:});
    end
end