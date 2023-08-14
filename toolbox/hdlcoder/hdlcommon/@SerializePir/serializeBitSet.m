function outStr=serializeBitSet(hC)

    outStr=' pirelab.getBitSetComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getBitSet),',',num2str(hC.getBitPos),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name)...
    ,',',num2str(hC.getUsingBitMask),');\n'];
end
