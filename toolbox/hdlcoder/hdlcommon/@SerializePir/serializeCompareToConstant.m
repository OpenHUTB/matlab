function outStr=serializeCompareToConstant(this,hC)

    outStr=' pirelab.getCompareToValueComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',hC.getOpName,'''',','...
    ,this.printConstantValue(hC,hC.getConstant),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),','...
    ,num2str(hC.getIsConstZero),');\n'];


end
