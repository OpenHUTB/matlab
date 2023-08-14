function outStr=serializeBitConcat(hC)

    outStr=' pirelab.getBitConcatComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),');\n'];

end
