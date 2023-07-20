function outStr=serializeBitReduce(hC)

    outStr=' pirelab.getBitReduceComp(hN,...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',hC.getMode,'''',','...
    ,SerializePir.printFormatString(hC.Name),');\n'];
end
