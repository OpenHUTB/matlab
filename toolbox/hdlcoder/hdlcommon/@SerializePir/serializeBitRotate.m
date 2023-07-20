function outStr=serializeBitRotate(hC)

    outStr=' pirelab.getBitRotateComp(hN,...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',hC.getOpName,'''',',',num2str(hC.getLength)...
    ,',',SerializePir.printFormatString(hC.Name),');\n'];

end
