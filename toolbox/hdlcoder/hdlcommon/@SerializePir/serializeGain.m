function outStr=serializeGain(this,hC)

    gainFactor=this.printConstantValue(hC,hC.getGainValue);
    gainMode=num2str(hC.getGainMode);
    constMultMode=num2str(hC.getConstMultiplierMode);
    roundMode=hC.getRoundingMode;
    overflowMode=hC.getOverflowMode;
    compName=SerializePir.printFormatString(hC.Name);
    dspMode=['int8(',num2str(hC.getDSPStyle),')'];

    if hC.hasGeneric
        outStr=' hNewC = ';
    else
        outStr=' ';
    end


    outStr=[outStr,' pirelab.getGainComp(hN, ...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',gainFactor,',',gainMode,','...
    ,constMultMode,',','''',roundMode,'''',',','''',overflowMode,'''',','...
    ,compName,',',dspMode,');\n'];

    if hC.hasGeneric
        numGenerics=hC.getNumGeneric;
        for ii=0:(numGenerics-1)
            genericPortName=hC.getGenericPortName(ii);
            genericPortValue=hC.getGenericPortValue(ii);

            outStr=[outStr,'\t\t hNewC.addGenericPort(','''',genericPortName,'''',','...
            ,this.printConstantValue(hC,genericPortValue),', pir_unsigned_t(32));\n'];%#ok<AGROW>
        end
    end

end
