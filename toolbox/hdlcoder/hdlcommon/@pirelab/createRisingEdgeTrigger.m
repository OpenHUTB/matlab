function hEdgeSig=createRisingEdgeTrigger(hN,hSig)



    hBoolT=pir_boolean_t;
    sigName=hSig.Name;
    hBoolSig=hN.addSignal(hBoolT,[sigName,'_bool']);
    pirelab.getDTCComp(hN,hSig,hBoolSig);

    hDelaySig=hN.addSignal(hBoolT,[sigName,'_delay']);
    pirelab.getIntDelayComp(hN,hBoolSig,hDelaySig,1);

    hInvSig=hN.addSignal(hBoolT,[hDelaySig.Name,'N']);
    pirelab.getLogicComp(hN,hDelaySig,hInvSig,'not');
    hEdgeSig=hN.addSignal(hBoolT,[sigName,'_rEdge']);
    pirelab.getLogicComp(hN,[hBoolSig,hInvSig],hEdgeSig,'and');
end
