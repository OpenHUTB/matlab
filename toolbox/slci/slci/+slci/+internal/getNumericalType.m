



function type=getNumericalType(type_str)
    valid=0;
    sign=0;
    word_len=0;
    fraction_len=0;
    nt=[];

    try
        nt=numerictype(type_str);
        valid=1;
    catch
        type=[valid,sign,word_len,fraction_len];
    end

    if(valid)
        assert(~isempty(nt));
        switch nt.Signedness
        case 'Signed'
            sign=1;
        case 'Unsigned'
            sign=0;
        end
        word_len=nt.WordLength;
        fraction_len=nt.FractionLength;
        type=[valid,sign,word_len,fraction_len];
    end
end