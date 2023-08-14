function hNewC=lowerConstant(hN,hC)







    hNewC=pireml.getConstComp(...
    hN,...
    hC.PirOutputSignals,...
    str2double(hC.getValue),...
    hC.Name);

end
