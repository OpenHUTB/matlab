function hNewC=lowerUnitDelay(hN,hC)




    hNewC=pireml.getUnitDelayComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.Name,...
    hC.getInitialValue,...
    hC.getResetNone,...
    '',...
    hC.SimulinkHandle);

end
