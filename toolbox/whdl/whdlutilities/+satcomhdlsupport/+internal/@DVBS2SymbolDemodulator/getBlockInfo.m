function blockInfo=getBlockInfo(this,hC)




    bfp=hC.SimulinkHandle;

    blockInfo.ModulationSourceParams=get_param(bfp,'ModulationSourceParams');
    if strcmp(blockInfo.ModulationSourceParams,'Property')
        blockInfo.ModulationScheme=get_param(bfp,'ModulationScheme');
        blockInfo.CodeRateAPSK=get_param(bfp,'CodeRateAPSK');
    end
    blockInfo.twoRootTwo=double(2*sqrt(2));
    blockInfo.UnitAveragePower=strcmp(get_param(bfp,'UnitAveragePower'),'on');
    blockInfo.DecisionType=get_param(bfp,'DecisionType');
    blockInfo.OutputType=get_param(bfp,'OutputType');
    blockInfo.EnbNoiseVar=strcmp(get_param(bfp,'EnbNoiseVar'),'on');
end
