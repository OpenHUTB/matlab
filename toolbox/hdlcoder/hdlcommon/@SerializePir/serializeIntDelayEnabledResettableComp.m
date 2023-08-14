function outStr=serializeIntDelayEnabledResettableComp(this,hC)

    initialVal='[]';
    if~isempty(hC.getInitialValue)
        initialVal=this.printConstantValue(hC,hC.getInitialValue);
    end
    defaultHwSemantics=num2str(hC.Owner.hasSLHWFriendlySemantics);

    enableSigs=' [] ';
    resetSigs=' [] ';
    idx=1;
    if hC.getHasExternalEnable
        hS=hC.PirInputSignals(idx);
        idx=idx+1;
        enableSigs=[matlab.lang.makeValidName(hS.Name),'_',hS.RefNum];
    end

    if hC.getHasExternalSyncReset
        hS=hC.PirInputSignals(idx);
        resetSigs=[matlab.lang.makeValidName(hS.Name),'_',hS.RefNum];
    end

    outStr=' pirelab.getIntDelayEnabledResettableComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',enableSigs,', ',resetSigs,', ...\n'];
    outStr=[outStr,'\t\t ','''',num2str(hC.getNumDelays),'''',','...
    ,SerializePir.printFormatString(hC.Name),',...\n'];
    outStr=[outStr,'\t\t ',initialVal,',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getResetNone),','];
    outStr=[outStr,defaultHwSemantics,')\n'];

end
