function ret=hasProxyTaskBlock(modelName)




    data=soc.blocks.proxyTaskData('get',modelName);
    ret=~isempty(data);
end
