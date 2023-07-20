function outStr=serializeRelOp(hC)
    mode=hC.ClassName;
    if strcmp(mode,'relop_comp')
        mode=hC.getOpName;
    end

    inputsamedt=0;
    if hC.getInputSameDT
        inputsamedt=1;
    end

    outStr=' pirelab.getRelOpComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ','''',mode,'''',','...
    ,num2str(inputsamedt),','...
    ,SerializePir.printFormatString(hC.Name),');\n'];

end
