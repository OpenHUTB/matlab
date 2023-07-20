function outStr=serializeDTCComp(hC)

    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        if ovMode
            ovMode='Saturate';
        else
            ovMode='Wrap';
        end
    end

    outStr=' pirelab.getDTCComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',rndMode,'''',',','''',ovMode,'''',','...
    ,'''',hC.getConversionMode,'''',','...
    ,SerializePir.printFormatString(hC.Name),');\n'];

end
