function hNewC=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    if strcmpi(blockInfo.inputSigns,'/')
        hC.Name='reciprocal';
    else
        hC.Name='divide';
    end

    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    if strcmpi(blockInfo.inputSigns,'/')
        hNewC=pirelab.getNonRestoreReciprocalComp(hN,hInSignals,hOutSignals,blockInfo);
    else

        hNewC=pirelab.getNonRestoreDivideComp(hN,hInSignals,hOutSignals,blockInfo);
    end
end
