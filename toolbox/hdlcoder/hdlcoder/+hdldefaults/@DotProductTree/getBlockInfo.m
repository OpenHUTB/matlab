function blockInfo=getBlockInfo(this,hC)



    slbh=hC.SimulinkHandle;
    saturate=strcmp(get_param(slbh,'SaturateOnIntegerOverflow'),'on');
    if saturate
        blockInfo.satMode='Saturate';
    else
        blockInfo.satMode='Wrap';
    end
    blockInfo.rndMode=get_param(slbh,'RndMeth');
