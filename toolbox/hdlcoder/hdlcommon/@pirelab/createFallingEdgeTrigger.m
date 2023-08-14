function hEdgeSig=createFallingEdgeTrigger(hN,hSig)



    hBoolT=pir_boolean_t;
    sigName=hSig.Name;
    hBoolSig=hN.addSignal(hBoolT,[sigName,'_bool']);
    pirelab.getDTCComp(hN,hSig,hBoolSig);

    hInvSig=hN.addSignal(hBoolT,[sigName,'N']);
    pirelab.getLogicComp(hN,hBoolSig,hInvSig,'not');

    hDelaySig=hN.addSignal(hBoolT,[hInvSig.Name,'_delay']);
    pirelab.getIntDelayComp(hN,hBoolSig,hDelaySig,1);

    hEdgeSig=hN.addSignal(hBoolT,[sigName,'_fEdge']);
    pirelab.getLogicComp(hN,[hInvSig,hDelaySig],hEdgeSig,'and');
end
