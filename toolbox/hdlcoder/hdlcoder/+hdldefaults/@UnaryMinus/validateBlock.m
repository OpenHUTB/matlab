function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    hInSignals=hC.PirInputSignals;

    hT=hInSignals.Type;
    if hT.isArrayType
        hT=hT.BaseType;
    end

    if hT.isWordType&&hT.WordLength>=128
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedWordLengthForUnaryMinus'));
    end
