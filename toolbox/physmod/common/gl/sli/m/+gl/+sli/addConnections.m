function addConnections(modelName,ss,srcBlock,srcPort,dstBlocks,dstPorts,pmioport)





    if~isempty(ss)
        sysName=[modelName,'/',strrep(ss,'.','/')];
    else
        sysName=modelName;
    end

    if numel(dstBlocks)~=numel(dstPorts)
        return;
    end

    for idx=1:numel(dstBlocks)
        add_line(sysName,[srcBlock,'/',srcPort],[dstBlocks{idx},'/',dstPorts{idx}],'autorouting','on');
    end

    if~isempty(pmioport)
        portHandles=get_param([sysName,'/',pmioport],'PortHandles');
        if~isempty(portHandles.LConn)
            add_line(sysName,[srcBlock,'/',srcPort],[pmioport,'/LConn1'],'autorouting','on');
        else
            add_line(sysName,[srcBlock,'/',srcPort],[pmioport,'/RConn1'],'autorouting','on');
        end
    end


end