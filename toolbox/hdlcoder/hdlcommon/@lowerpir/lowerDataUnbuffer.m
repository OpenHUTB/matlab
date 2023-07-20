function hNewC=lowerDataUnbuffer(hN,hC)



    ic=hC.getCounterInit;
    if isempty(ic)
        ic=1;
    end



    hNewC=pireml.getDataUnbufferComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    ic,...
    hC.Name);

end
