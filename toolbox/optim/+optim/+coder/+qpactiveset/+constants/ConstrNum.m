function val=ConstrNum(cname)



















%#codegen

    coder.allowpcode('plain');


    switch cname
    case 'FIXED'
        val=coder.internal.indexInt(1);
    case 'AEQ'
        val=coder.internal.indexInt(2);
    case 'AINEQ'
        val=coder.internal.indexInt(3);
    case 'LOWER'
        val=coder.internal.indexInt(4);
    case 'UPPER'
        val=coder.internal.indexInt(5);
    otherwise
        assert(false,'qpactiveset_ConstrNum unexpected input');
    end

end

