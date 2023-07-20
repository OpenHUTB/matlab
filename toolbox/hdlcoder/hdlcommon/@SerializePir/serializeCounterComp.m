function outStr=serializeCounterComp(hC)

    type=hC.getCountType;
    initval=num2str(hC.getCountInit);
    stepval=num2str(hC.getCountStep);
    maxval=num2str(hC.getCountMax);
    if isempty(maxval)
        maxval='[]';
    end
    countFrom=num2str(hC.getCountFrom);
    resetport=num2str(hC.getResetPort);
    enbport=num2str(hC.getEnablePort);
    loadport=num2str(hC.getLoadPort);
    dirport=num2str(hC.getDirectionPort);
    compName=SerializePir.printFormatString(hC.Name);

    outStr=' pirelab.getCounterComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',type,'''',',',initval,','...
    ,stepval,',',maxval,',',resetport,',',loadport,','...
    ,enbport,',',dirport,',',compName,',',countFrom,');\n'];

end
