function hNewC=lowerBitShiftLib(hN,hC)



    opmode=hC.getOpName;

    if strcmpi(opmode,'shift left logical')
        shiftMode='sll';
    elseif strcmpi(opmode,'shift right logical')
        shiftMode='srl';
    elseif strcmpi(opmode,'shift right arithmetic')
        shiftMode='sra';
    end

    hNewC=pireml.getBitShiftComp(hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    shiftMode,...
    hC.getShiftLength,...
    0,...
    hC.Name);
end
