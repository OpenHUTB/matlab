function outStr=serializeUnitDelay(this,hC)

    outStr=' pirelab.getUnitDelayComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),',...\n'];
    outStr=[outStr,'\t\t ',this.printConstantValue(hC,hC.getInitialValue),',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getResetNone),');\n'];

end
