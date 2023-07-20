function outStr=serializeBitwiseOp(this,hC)

    outStr=' pirelab.getBitwiseOpComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',hC.getOpName,'''',','...
    ,SerializePir.printFormatString(hC.Name),','...
    ,num2str(hC.getUseBitMask),',...\n'];
    outStr=[outStr,'\t\t ',this.printConstantValue(hC,hC.getBitMask)...
    ,',',num2str(hC.getIsBitMaskZero),');\n'];

end
