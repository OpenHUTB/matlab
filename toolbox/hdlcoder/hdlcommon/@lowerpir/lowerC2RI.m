function hNewC=lowerC2RI(hN,hC)



    hInType=hC.PirInputSignals(1).Type;
    dimLen=double(max(hInType.getDimensions));

    if(dimLen>1)
        hInType=hInType.BaseType;
    end

    if~hInType.isComplexType
        hNewC=pireml.getComplex2RealImag(...
        hN,...
        hC.PirInputSignals,...
        hC.PirOutputSignals,...
        hC.getMode,...
        hC.Name);
    else



        hNewC=hC;
    end

end
