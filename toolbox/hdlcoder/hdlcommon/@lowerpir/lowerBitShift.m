function hNewC=lowerBitShift(hN,hC)



    hNewC=pireml.getBitShiftComp(hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.getOpName,...
    hC.getShiftLength,...
    hC.getBinPtShiftLength,...
    hC.Name);
end
