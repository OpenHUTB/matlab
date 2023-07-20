function outStr=serializeBitSlice(hC)

    outStr=' pirelab.getBitSliceComp(hN,...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getLeftIndex),',',num2str(hC.getRightIndex)...
    ,',',SerializePir.printFormatString(hC.Name),');\n'];
end
