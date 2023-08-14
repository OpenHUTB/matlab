function elabConnectToOutput(this,hN,inSig,totalLatency,blockInfo)%#ok<INUSL>






    outSig=hN.PirOutputSignals;



    CbdtcOutType=outSig(1).Type;
    CbdtcOutName=[inSig(1).Name,'_conv'];
    CbdtcOutSig=hN.addSignal(CbdtcOutType,CbdtcOutName);
    castCbComp=pirelab.getDTCComp(hN,inSig(1),CbdtcOutSig,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    castCbComp.addComment('Apply fixed-point math settings (RoundingMethod and OverflowAction) and cast Cb output to its input data type');

    pirelab.getUnitDelayComp(hN,CbdtcOutSig,outSig(1),'CbOut');

    CrdtcOutType=outSig(2).Type;
    CrdtcOutName=[inSig(2).Name,'_conv'];
    CrdtcOutSig=hN.addSignal(CrdtcOutType,CrdtcOutName);
    castCrComp=pirelab.getDTCComp(hN,inSig(2),CrdtcOutSig,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    castCrComp.addComment('Apply fixed-point math settings (RoundingMethod and OverflowAction) and cast Cr output to its input data type');

    pirelab.getUnitDelayComp(hN,CrdtcOutSig,outSig(2),'CrOut');


    totalLatency=totalLatency+1;





    deComment={'Delay Y Component',...
    'Delay Horizontal Start',...
    'Delay Horizontal End',...
    'Delay Vertical Start',...
    'Delay Vertical End',...
    'Delay Valid'};
    assert(numel(outSig)==8);
    for ii=3:numel(outSig)
        de=pirelab.getIntDelayComp(hN,inSig(ii),outSig(ii),totalLatency,...
        [outSig(ii).Name,'_fir_latency']);
        de.addComment(deComment{ii-2});
    end

end
