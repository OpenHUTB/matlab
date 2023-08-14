function outStr=serializeSwitch(hC)

    criteria=hC.getCompareStr;
    compareVal=hC.getThreshold;
    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        assert(false,"Unexpected type for overflow mode");
    end

    outStr=' pirelab.getSwitchComp(hN, ...\n';
    inSignals=[hC.PirInputSignals(1),hC.PirInputSignals(3)];
    outStr=[outStr,'\t\t [',matlab.lang.makeValidName(inSignals(1).Name),'_',inSignals(1).RefNum,','...
    ,matlab.lang.makeValidName(inSignals(2).Name),'_',inSignals(2).RefNum,'],...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    selSignal=hC.PirInputSignals(2);
    outStr=[outStr,'\t\t',matlab.lang.makeValidName(selSignal.Name),'_',selSignal.RefNum,','...
    ,SerializePir.printFormatString(hC.Name),',...\n'];%#ok<*AGROW>
    outStr=[outStr,'\t\t ','''',criteria,'''',',',num2str(compareVal),','...
    ,'''',rndMode,'''',',','''',ovMode,'''',');\n'];

end

