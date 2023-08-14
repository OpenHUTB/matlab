function outStr=serializeLogic(hC)
    op=hC.ClassName;
    if strcmp(op,'logic_comp')
        op=hC.getOpName;
    end
    outStr=' pirelab.getLogicComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',op,'''',','...
    ,SerializePir.printFormatString(hC.Name),');\n'];
end
