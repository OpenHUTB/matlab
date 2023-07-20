function tbCheckerComp=getTBCheckerComp(hN,hInSignals,hOutSignals)



    narginchk(3,3);

    sigType=hInSignals(3).Type;
    isSignalFloat=sigType.BaseType.isFloatType;

    tbCheckerComp=hN.addComponent2(...
    'kind','tb_checker_comp',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'IsSignalFloat',isSignalFloat);
end


