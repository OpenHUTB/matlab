function blockInfo=getBlockInfo(this,hC)




    bfp=hC.SimulinkHandle;

    blockInfo.ModulationSourceParams=get_param(bfp,'ModulationSourceParams');
    if strcmp(blockInfo.ModulationSourceParams,'Property')
        blockInfo.ModulationScheme=get_param(bfp,'ModulationScheme');
        blockInfo.CodeRateAPSK=get_param(bfp,'CodeRateAPSK');
    end
    blockInfo.UnitAveragePower=strcmp(get_param(bfp,'UnitAveragePower'),'on');
    blockInfo.OutputDataType=get_param(bfp,'OutputDataType');
    if strcmp(blockInfo.OutputDataType,'Custom')
        m=this.hdlslResolve('WordLength',bfp);
        blockInfo.WordLength=double(m);
    end
end