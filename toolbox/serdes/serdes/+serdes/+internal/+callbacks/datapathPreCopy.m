






function datapathPreCopy(block)




    nodes=strsplit(block,'/');
    validLocation=length(nodes)>=3&&...
    (strcmp(nodes{2},'Rx')||strcmp(nodes{2},'Tx'));

    if~validLocation
        msgId='serdes:callbacks:InvalidBlockLocation';
        error(message(msgId,block));
    end
end
