function outStr=serializeIntegerDelay(this,hC)

    defaultHwSemantics=num2str(hC.Owner.hasSLHWFriendlySemantics);
    initialVal='[]';
    if~isempty(hC.getInitialValue)
        initialVal=this.printConstantValue(hC,hC.getInitialValue);
    end

    outStr=' pirelab.getIntDelayComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getNumDelays),','...
    ,SerializePir.printFormatString(hC.Name),',...\n'];
    outStr=[outStr,'\t\t ',initialVal,',...\n'];
    outStr=[outStr,'\t\t ',num2str(hC.getResetNone),',',num2str(0),','...
    ,'[],',num2str(hC.getRAMBased),','...
    ,defaultHwSemantics,');\n'];

end
