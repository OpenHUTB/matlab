function hNewC=lowerDeadZoneDynamic(hN,hC)



    hNewC=pireml.getDeadZoneDynamicComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.Name);

end
