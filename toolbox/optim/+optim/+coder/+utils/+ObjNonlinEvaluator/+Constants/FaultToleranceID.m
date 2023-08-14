function val=FaultToleranceID(cname)













%#codegen

    coder.allowpcode('plain');


    switch cname
    case 'NaN'
        val=coder.internal.indexInt(-3);
    case 'PosInf'
        val=coder.internal.indexInt(-2);
    case 'NegInf'
        val=coder.internal.indexInt(-1);
    case 'Success'
        val=coder.internal.indexInt(1);
    otherwise
        assert(false,'FaultToleranceID() unexpected input');
    end

end