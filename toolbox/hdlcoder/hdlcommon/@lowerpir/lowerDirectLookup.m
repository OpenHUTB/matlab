function hNewC=lowerDirectLookup(hN,hC)





    hNewC=pireml.getDirectLookupComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.getTableData,...
    hC.Name,...
    hC.getDiagnostics);

end
