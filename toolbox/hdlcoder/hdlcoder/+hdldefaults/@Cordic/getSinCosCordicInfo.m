function cordicInfo=getSinCosCordicInfo(numIter,fcnName,inputWL)










    cordicInfo.iterNum=double(numIter);


    if(cordicInfo.iterNum<0)

        if inputWL<2
            error(message('fixed:cordic:inputWordLengthNotGTOne'));
        end
        cordicInfo.iterNum=inputWL-1;
    end


    cordicInfo.networkName=[fcnName,'_niter_',num2str(cordicInfo.iterNum)];

    intermWL=inputWL;
    intermFL=inputWL-2;
    intermDT=numerictype(1,intermWL,intermFL);
    sf=scale_factor(cordicInfo.iterNum);
    cordicInfo.scaleFactor=fi(sf,intermDT);

    intermDT=numerictype(cordicInfo.scaleFactor);
    cordicInfo.lutValue=fi(atan(1./(2.^((0:cordicInfo.iterNum-1).'))),intermDT);

end

function sf=scale_factor(niter)

    MAX_KFACTOR=30;
    niter=min(niter,MAX_KFACTOR);

    scalingFactor=[
    0.70710678118654746171500846685376018285751342773437500,...
    0.63245553203367588235295215781661681830883026123046875,...
    0.61357199107789628378384350071428343653678894042968750,...
    0.60883391251775242913879537809407338500022888183593750,...
    0.60764825625616813997709186878637410700321197509765625,...
    0.60735177014129593242586224732804112136363983154296875,...
    0.60727764409352602559266642856528051197528839111328125,...
    0.60725911229889284470573329599574208259582519531250000,...
    0.60725447933256238020049977421876974403858184814453125,...
    0.60725332108987517543141620990354567766189575195312500,...
    0.60725303152913434612258924971683882176876068115234375,...
    0.60725295913894483668116208718856796622276306152343750,...
    0.60725294104139726503177598715410567820072174072265625,...
    0.60725293651701028885270261525874957442283630371093750,...
    0.60725293538591351705235865665599703788757324218750000,...
    0.60725293510313937961342389826313592493534088134765625,...
    0.60725293503244570647581213052035309374332427978515625,...
    0.60725293501477239921371165110031142830848693847656250,...
    0.60725293501035404464261091561638750135898590087890625,...
    0.60725293500924948375541134737432003021240234375000000,...
    0.60725293500897326026688460842706263065338134765625000,...
    0.60725293500890431541705538620590232312679290771484375,...
    0.60725293500888699593787123376387171447277069091796875,...
    0.60725293500888266606807519565336406230926513671875000,...
    0.60725293500888155584505057049682363867759704589843750,...
    0.60725293500888133380044564546551555395126342773437500,...
    0.60725293500888133380044564546551555395126342773437500,...
    0.60725293500888133380044564546551555395126342773437500,...
    0.60725293500888133380044564546551555395126342773437500,...
    0.60725293500888133380044564546551555395126342773437500];
    sf=scalingFactor(niter);
    return;
end