function outStr=serializeAdd(this,hC)
    rndMode=hC.getRoundingMode;
    ovMode=hC.getOverflowMode;
    if~ischar(ovMode)
        if ovMode
            ovMode='Saturate';
        else
            ovMode='Wrap';
        end
    end
    accType=hC.getAccumulatorType;
    if isempty(accType)
        slPirType=' [] ';
    else
        accPirType=pirgetdatatypeinfo(accType);
        accSLType=accPirType.sltype;
        slPirType=this.getType(accSLType);
    end
    inputSigns=hC.getInputSigns;

    outStr=' pirelab.getAddComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t','''',rndMode,'''',',','''',ovMode,'''',','...
    ,SerializePir.printFormatString(hC.Name)...
    ,',',slPirType,','...
    ,'''',inputSigns,'''',');\n'];

end
