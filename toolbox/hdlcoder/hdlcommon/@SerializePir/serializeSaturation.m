function outStr=serializeSaturation(this,hC)

    lowerLimit=this.printConstantValue(hC,hC.getLowerLimit);
    upperLimit=this.printConstantValue(hC,hC.getUpperLimit);
    rounding=hC.getRoundingMode;
    compName=SerializePir.printFormatString(hC.Name);

    outStr=' pirelab.getGainComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',lowerLimit,',',upperLimit,','...
    ,'''',rounding,'''',',',compName,');\n'];

end
