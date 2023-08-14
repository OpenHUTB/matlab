function outStr=serializeUnaryMinusComp(hC)
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        assert(false,"Unexpected type for overflow mode");
    end

    outStr=' pirelab.getUnaryMinusComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',ovMode,'''',',',SerializePir.printFormatString(hC.Name),');\n'];

end
