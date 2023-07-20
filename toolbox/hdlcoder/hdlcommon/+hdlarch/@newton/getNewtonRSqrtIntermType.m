function intermType=getNewtonRSqrtIntermType(hInSignals,hOutSignals,intermDT,internalRule)




    din=hInSignals(1);
    dout=hOutSignals(1);


    inputType=din.Type.getLeafType;
    inputWL=inputType.WordLength;


    outputType=dout.Type.getLeafType;
    outputWL=outputType.WordLength;


    if strcmpi(intermDT,'Input')
        intermWL=inputWL;
        intermFL=inputWL-4;
        intermType=pir_sfixpt_t(intermWL,-intermFL);
    elseif strcmpi(intermDT,'Output')
        intermWL=outputWL;
        intermFL=outputWL-4;
        intermType=pir_sfixpt_t(intermWL,-intermFL);
    elseif strcmpi(intermDT,'InternalRule')
        intermType=pirelab.convertSLType2PirType(internalRule);
    else
        error(message('hdlcommon:hdlcommon:IncorrentIntermDT'));
    end