function tooltipInfo=GetDESRuntimeBadgeTooltipInfo(blockpath)









    modelName=bdroot(blockpath);
    modelHandle=get_param(modelName,'handle');
    rt=simevents.ModelRoot.get(modelHandle);
    blkHdl=getSimulinkBlockHandle(blockpath);

    tooltipInfo='';
    for idx=1:length(rt.getBlock(blkHdl).Storage)
        entities=rt.getBlock(blkHdl).Storage(idx).Entity;

        tooltipInfo=[tooltipInfo,...
        rt.getBlock(blkHdl).Storage(idx).Type,num2str(idx),': ',...
        '#Elements: ',num2str(length(entities)),char(10)];
    end
