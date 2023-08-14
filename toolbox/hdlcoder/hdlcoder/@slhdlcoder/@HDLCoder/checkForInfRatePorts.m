function infRatePortName=checkForInfRatePorts(this)



    infRatePortName=[];
    if this.isDutModelRef
        subMdlName=get_param(this.OrigStartNodeName,'ModelName');
        load_system(subMdlName);
        blocklist=getCompiledBlockList(get_param(subMdlName,'ObjectAPI_FP'));
    else
        blocklist=getCompiledBlockList(get_param(this.getStartNodeName,'ObjectAPI_FP'));
    end
    ports=getPorts(blocklist);
    for ii=1:numel(ports)
        rate=get_param(ports(ii),'CompiledSampleTime');
        if isinf(rate(1))
            infRatePortName=get_param(ports(ii),'Name');
            break;
        end
    end
end

function ports=getPorts(blocklist)
    ports=[];
    for ii=1:numel(blocklist)
        try
            typ=get_param(blocklist(ii),'BlockType');
            if strcmp(typ,'Inport')||strcmp(typ,'Outport')
                ports(end+1)=blocklist(ii);%#ok<AGROW>
            end
        catch

        end
    end
end
