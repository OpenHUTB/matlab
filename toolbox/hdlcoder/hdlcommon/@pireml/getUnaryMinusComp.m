function unaryMinusComp=getUnaryMinusComp(hN,hInSignals,hOutSignals,oType_ex,compName)



    if(nargin<5)
        compName='uminus';
    end

    if(nargin<4)
        oType_ex=pirelab.getTypeInfoAsFi(hOutSignals.Type);
    end

    hT=hInSignals(1).Type;
    if hT.isArrayType
        hT=hT.BaseType;
    end

    if hT.isWordType&&hT.WordLength>=128
        error(message('hdlcoder:validate:UnsupportedWordLengthForUnaryMinus'));
    end


    unaryMinusComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_unaryminus',...
    'EMLParams',{oType_ex},...
    'EMLFlag_TreatInputBoolsAsUfix1','true');

    unaryMinusComp.runLoopUnrolling(false);

end
