function getHalfUnpackComp(hN,hInSignals,hOutSignals,compName)
    hNewC=hN.addComponent2('kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','nfp_unpack16',...
    'EMLParams',{});
    hNewC.treatInputIntsAsFixpt(false);
    hNewC.treatInputBoolsAsUfix1(false);
    hNewC.saturateOnIntOverflow(false);
    hNewC.addComment('Split 16 bit word into FP sign, exponent, mantissa');
end
