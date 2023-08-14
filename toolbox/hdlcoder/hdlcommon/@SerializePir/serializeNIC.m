function outStr=serializeNIC(hC)

    hCName=matlab.lang.makeValidName(hC.Name);
    hCFullPath=hC.ReferenceNetwork.FullPath;
    outStr=['hRefN = p.findNetwork(''fullname'', ','''',hCFullPath,'''',');\n'];
    outStr=[outStr,'\t ',hCName,'= hN.addComponent(''ntwk_instance_comp'', hRefN);\n'];
    outStr=[outStr,'\t\t ',hCName,'.Name = ',SerializePir.printFormatString(hC.Name),';\n'];

    outStr=[outStr,'\t\t pirelab.connectNtwkInstComp(',hCName,',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompInputs(hC),',...\n'];
    outStr=[outStr,'\t\t ',SerializePir.printCompOutputs(hC),');\n'];

    if hC.hasGeneric
        numGenerics=hC.getNumGeneric;
        for ii=0:(numGenerics-1)
            genericPortName=hC.getGenericPortName(ii);
            genericPortValue=hC.getGenericPortValue(ii);

            outStr=[outStr,'\t\t ',hCName,'.addGenericPort(','''',genericPortName,'''',','...
            ,this.printConstantValue(hC,genericPortValue),', pir_unsigned_t(32));\n'];%#ok<AGROW>
        end
    end
    comment=hC.getComment();
    if~isempty(comment)
        ssStr=SerializePir.printFormatString(comment);
        outStr=[outStr,'\t\t',hCName,'.addComment(',ssStr,');\n'];
    end
end
