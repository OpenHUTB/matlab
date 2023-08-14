function hNewC=lowerMux(hN,hC)


    hInType=hC.PirInputSignals(2).Type;
    hOutType=hC.PirOutputSignals(1).Type;
    if hInType.isArrayType&&all(hInType.getDimensions~=hOutType.getDimensions)
        inputmode=2;
    else
        inputmode=1;
    end

    if isempty(hC.getZeroBasedIndex)||hC.getZeroBasedIndex==1
        dataPortOrder='Zero-based contiguous';
    else
        dataPortOrder='One-based contiguous';
    end
    hNewC=pireml.getMultiPortSwitchComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    inputmode,...
    dataPortOrder,...
    hC.getRoundingMode,...
    hC.getOverflowMode,...
    hC.Name);
end
