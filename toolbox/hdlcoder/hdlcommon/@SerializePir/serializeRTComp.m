function outStr=serializeRTComp(~,hC)
    compName=SerializePir.printFormatString(hC.Name);
    initValStr=num2str(hC.getInitialValue);
    if isempty(initValStr)
        initValStr='[]';
    end

    outStr=' hN.addComponent2( ''kind'' , ''ratetransition'', ...\n';
    outStr=[outStr,'\t\t ''SimulinkHandle'' , -1, ...\n'];
    outStr=[outStr,'\t\t ''Name'' ,',compName,',...\n'];
    outStr=[outStr,'\t\t ''InputSignals'' ,',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ''OutputSignals'' ,',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ''Factor'' ,',num2str(hC.getFactor),',...\n'];
    outStr=[outStr,'\t\t ''RateUp'' ,',num2str(hC.getRateup),',...\n'];
    outStr=[outStr,'\t\t ''InitialValue'' ,',initValStr,',...\n'];
    outStr=[outStr,'\t\t ''ResetInitVal'' ,',num2str(hC.getResetInitVal),',...\n'];
    outStr=[outStr,'\t\t ''BlockComment'' , '' '' );\n'];

end
