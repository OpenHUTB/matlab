function hNewC=lowerUnaryMinus(hN,hC)



    hOutSignals=hC.PirOutputSignals;
    hType=pirelab.getTypeInfoAsFi(hOutSignals.Type,'floor',hC.getOverflowMode);

    hNewC=pireml.getUnaryMinusComp(...
    hN,...
    hC.PirInputSignals,...
    hOutSignals,...
    hType,...
    hC.Name);

end
