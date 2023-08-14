function outStr=serializeRepeat(~,hC)

    rptCount=num2str(hC.getRepetitionCount);
    compName=SerializePir.printFormatString(hC.Name);

    outStr=' pirelab.getRepeatComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',rptCount,',',compName,');\n'];

end
