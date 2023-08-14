function outStr=serializeBitExtract(hC)

    outStr=' pirelab.getBitExtractComp(hN,...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getUpperLimit),',',num2str(hC.getLowerLimit)...
    ,',',num2str(hC.getTreatAsInteger),','...
    ,SerializePir.printFormatString(hC.Name),');\n'];

end
