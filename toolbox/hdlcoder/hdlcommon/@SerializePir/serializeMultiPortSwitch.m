function outStr=serializeMultiPortSwitch(hC)

    inputMode=num2str(hC.getInputMode);
    dpOrder=hC.getDataPortOrder;
    rndMode=hC.getRoundingMode;
    overflowMode=hC.getOverflowMode;
    if~ischar(overflowMode)
        assert(false,"Unexpected type for overflow mode");
    end
    compName=SerializePir.printFormatString(hC.Name);
    portIndices=hC.getPortIndices;
    portSel='[';
    for ii=1:length(portIndices)
        portSel=[portSel,num2str(portIndices(ii))];%#ok<*AGROW>
        if ii<length(portIndices)
            portSel=[portSel,','];
        end
    end
    portSel=[portSel,']'];

    outStr=' pirelab.getMultiPortSwitchComp(hN, ...\n';
    outStr=[outStr,'\t\t',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t',inputMode,',','''',dpOrder,'''',','...
    ,'''',rndMode,'''',',','''',overflowMode,'''',',',compName...
    ,',',portSel,');\n'];

end

