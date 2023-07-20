function portName=checkTopLevelBusPorts(~,slName)



    portName=[];
    if strcmp(get_param(slName,'BlockType'),'ModelReference')
        subMdlName=get_param(slName,'ModelName');
        blocklist=getCompiledBlockList(get_param(subMdlName,'ObjectAPI_FP'));
    else
        blocklist=getCompiledBlockList(get_param(slName,'ObjectAPI_FP'));
    end
    ports=getPorts(blocklist);


    bsWarn=warning('off','Simulink:blocks:StrictMsgIsSetToNonStrict');
    slw=sllastwarning;
    [lw,lwid]=lastwarn;
    for ii=1:numel(ports)
        phan=get_param(ports(ii),'PortHandles');
        if strcmp(get_param(ports(ii),'BlockType'),'Inport')
            porthandle=phan.Outport;
        else
            porthandle=phan.Inport;
        end
        busStruct=get_param(porthandle,'CompiledBusStruct');
        if~isempty(busStruct)
            portName=getfullname(ports(ii));
        end
    end

    [~]=warning(bsWarn.state,'Simulink:blocks:StrictMsgIsSetToNonStrict');
    sllastwarning(slw);
    lastwarn(lw,lwid);
end

function ports=getPorts(blocklist)
    ports=[];
    for ii=1:numel(blocklist)
        typ=get_param(blocklist(ii),'BlockType');
        if strcmp(typ,'Inport')||strcmp(typ,'Outport')
            ports(end+1)=blocklist(ii);%#ok<AGROW>
        end
    end
end