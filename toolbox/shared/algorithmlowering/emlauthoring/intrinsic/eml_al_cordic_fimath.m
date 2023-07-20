function cordicFimath=eml_al_cordic_fimath(inputVar)



%#codegen

    coder.allowpcode('plain');
    eml_assert(~isfloat(inputVar));


    inputVarType=eml_al_numerictype(inputVar);
    ioWordLength=inputVarType.WordLength;
    ioFracLength=ioWordLength-2;



    cordicFimath=fimath('SumMode','SpecifyPrecision',...
    'SumWordLength',ioWordLength,...
    'SumFractionLength',ioFracLength,...
    'RoundMode','floor',...
    'OverflowMode','wrap'...
    );
