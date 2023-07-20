function outStr=serializeBitShift(hC)

    shiftMode=hC.getOpName;
    if strcmpi(shiftMode,'shift left logical')
        shiftMode='sll';
    elseif strcmpi(shiftMode,'shift right logical')
        shiftMode='srl';
    elseif strcmpi(shiftMode,'shift right arithmetic')
        shiftMode='sra';
    end

    outStr=' pirelab.getBitShiftComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',shiftMode,'''',','...
    ,num2str(hC.getShiftLength),',',num2str(hC.getBinPtShiftLength),','...
    ,SerializePir.printFormatString(hC.Name),');\n'];

end
