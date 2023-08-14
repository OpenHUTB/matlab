function hNewC=lowerFilter(hN,hC)



    filterImpl=hC.getFilterImpl;
    hNewC=pireml.getFilterComp(hN,hC,filterImpl);

end
