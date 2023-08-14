function outStr=serializeUpSample(~,hC)
    factor=num2str(hC.getFactor);
    offset=num2str(hC.getOffset);
    initVal=num2str(hC.getInitialValue);

    outStr=' pirelab.getUpSampleComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',factor,',',offset,',',initVal,',',SerializePir.printFormatString(hC.Name),');\n'];

end
