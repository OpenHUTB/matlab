function hNewC=lowerPreLookup(hN,hC)



    hNewC=pireml.getPreLookupComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    hC.getBpData,...
    hC.getBpType,...
    hC.getKType,...
    hC.getFractionType,...
    hC.getIdxOnly,...
    hC.getPowerOf2,...
    hC.Name);

end
