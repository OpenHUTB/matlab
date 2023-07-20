function hCNew=elaborate(this,hN,hC)






    import pirelab.numerictype2pirType

    blkInfo=this.getBlockInfo(hC);
    divByConstBlkInfo=blkInfo;
    divByConstBlkInfo.roundingMethod='Floor';

    topNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',{'X','validIn'},...
    'OutportNames',{'Y','validOut'},...
    'Name','modimpl_ntwk');
    inSignals=topNet.PirInputSignals();
    outSignals=topNet.PirOutputSignals();

    for ii=1:length(inSignals)
        outSignals(ii).SimulinkRate=blkInfo.SimulinkRate;
    end


    switch blkInfo.algorithm
    case{fixed.internal.mod.algorithm.AlgorithmEnum.CastToPow2,...
        fixed.internal.mod.algorithm.AlgorithmEnum.ReturnInput}
        this.elabModViaCast(topNet,topNet.PirInputSignals(1),topNet.PirOutputSignals(1),blkInfo);
    otherwise

        mulRndIn=inSignals(1);
        mulRndOut=topNet.addSignal(numerictype2pirType(blkInfo.typesTable.pOutputPrototype),'mulrndout');
        inDlyOut=topNet.addSignal(inSignals(1).Type,'inDlyOut');
        mulDenomOut=topNet.addSignal(numerictype2pirType(blkInfo.typesTable.subtractionType),'mulDenomOut');


        mulRnd=emblibhdl.DivideByConstant();
        mulRnd.makeMulRndDatapath(topNet,mulRndIn,mulRndOut,divByConstBlkInfo);
        pirelab.getIntDelayComp(topNet,mulRndIn,inDlyOut,7,'xin_dly',0,true);
        this.makeMulByDenominator(topNet,mulRndOut,mulDenomOut,blkInfo);
        this.makeSubNet(topNet,[inDlyOut,mulDenomOut],topNet.PirOutputSignals(1),blkInfo);
    end

    if length(inSignals)>1
        this.makeValidLine(topNet,inSignals(2),outSignals(2),blkInfo);
    end

    hCNew=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,'mod_by_constant');

end
