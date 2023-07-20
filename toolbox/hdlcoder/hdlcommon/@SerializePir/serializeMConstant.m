function outStr=serializeMConstant(this,hC)

    vectorParamsId=hC.getVectorParams1D;
    isConstZero=hC.getIsConstZero;
    tunableParamStr=hC.getTunableParamStr;
    constBusName=hC.getConstBusName;
    constBusType=hC.getConstBusType;

    if hC.hasGeneric
        outStr=' hNewC = ';
    else
        outStr=' ';
    end

    outStr=[outStr,' pirelab.getConstComp(hN, ...\n'];
    outStr=[outStr,'\t\t',SerializePir.printCompOutputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',this.printConstantValue(hC,hC.getConstantValue),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),','...
    ,'''',vectorParamsId,'''',',',num2str(isConstZero),','...
    ,'''',tunableParamStr,'''',',','''',constBusName,'''',','...
    ,'''',constBusType,'''',');\n'];

    if hC.hasGeneric
        numGenerics=hC.getNumGeneric;
        for ii=0:(numGenerics-1)
            genericPortName=hC.getGenericPortName(ii);
            genericPortValue=hC.getGenericPortValue(ii);

            outStr=[outStr,'\t\t hNewC.addGenericPort(','''',genericPortName,'''',','...
            ,this.printConstantValue(hC,genericPortValue),', pir_unsigned_t(32));\n'];%#ok<AGROW>
        end
    end

end
