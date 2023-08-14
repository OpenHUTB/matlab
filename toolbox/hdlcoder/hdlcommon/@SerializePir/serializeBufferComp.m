function outStr=serializeBufferComp(hC)

    outStr=' pirelab.getWireComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),');\n'];

end
