function hNewC=lowerSaturation(hN,hC)



    hNewC=pireml.getSaturateComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.getLowerLimit,...
    hC.getUpperLimit,...
    hC.getRoundingMode,...
    hC.Name);

end
