function hNewC=lowerBacklash(hN,hC)



    hNewC=pireml.getBacklashComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.getBacklashWidth,...
    hC.getInitialOutput,...
    hC.Name);

end
