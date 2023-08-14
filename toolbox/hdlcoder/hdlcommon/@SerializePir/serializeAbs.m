function outStr=serializeAbs(hC)
    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        ovMode=num2str(ovMode);
    end

    outStr=' pirelab.getAbsComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',rndMode,'''',',','''',ovMode,'''',','...
    ,SerializePir.printFormatString(hC.Name),');\n'];
end
