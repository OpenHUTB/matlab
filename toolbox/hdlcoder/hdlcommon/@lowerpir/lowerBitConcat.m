function hNewC=lowerBitConcat(hN,hC)





    hOutSignals=hC.PirOutputSignals;
    outSignalType=hOutSignals(1).Type.BaseType;
    if outSignalType.WordLength>128
        hNewC=pircore.getBitConcatComp(hN,...
        hC.PirInputSignals,...
        hC.PirOutputSignals,...
        hC.Name);
    else
        hNewC=pireml.getBitConcatComp(hN,...
        hC.PirInputSignals,...
        hC.PirOutputSignals,...
        hC.Name);
    end

end
