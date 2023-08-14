function hSignal=addPirSignal(hN,hIOPort)




    isSigned=hIOPort.Signed;
    wordLength=hIOPort.WordLength;
    fracLength=hIOPort.FractionLength;

    if isSigned
        baseType=pir_sfixpt_t(wordLength,fracLength);
    else
        baseType=pir_ufixpt_t(wordLength,fracLength);
    end

    if hIOPort.isVector
        dimNum=hIOPort.Dimension;
        portType=pirelab.getPirVectorType(baseType,dimNum);
    else
        portType=baseType;
    end

    sigName=sprintf('%s_sig',hIOPort.PortName);

    hSignal=hN.addSignal(portType,sigName);

end