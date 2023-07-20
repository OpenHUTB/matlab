function outStr=serializeDynamicBitShift(hC)

    shiftMode=hC.getShiftMode;

    outStr=' pirelab.getDynamicBitShiftComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',shiftMode,'''',','...
    ,SerializePir.printFormatString(hC.Name),');\n'];

end
