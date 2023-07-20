function outStr=serializeMultiply(hC)

    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        assert(false,"Unexpected type for overflow mode");
    end
    inputSigns=hC.getInputSigns;
    dspStyle=hC.getDSPStyle;

    outStr=' pirelab.getMulComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',rndMode,'''',',','''',ovMode,'''',','...
    ,SerializePir.printFormatString(hC.Name),',','''',inputSigns,''''...
    ,', '''', -1,',num2str(dspStyle),');\n'];

end
