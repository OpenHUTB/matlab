function blocks=getLineDestBlocks(line)




    ports=SLStudio.Utils.getLineDestPorts(line);
    blocks={};
    for iter=1:length(ports)
        blocks=[blocks,ports(iter).container];%#ok<AGROW>
    end
end
