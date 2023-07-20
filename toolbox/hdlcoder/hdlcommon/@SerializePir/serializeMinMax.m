function outStr=serializeMinMax(hC)

    opName=hC.getOpName;
    isDSPBlk=hC.getisDSPBlk;
    outputMode=hC.getOutputMode;
    isOneBased=hC.getisOneBased;

    outStr=' pirelab.getMinMaxComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printFormatString(hC.Name),','...
    ,'''',opName,'''',',',num2str(isDSPBlk),',','''',outputMode,''''...
    ,',',num2str(isOneBased),');\n'];

end
