function val=CentralFiniteDifferenceID(cname)













%#codegen

    coder.allowpcode('plain');


    switch cname
    case 'Central'
        val=coder.internal.indexInt(0);
    case 'DoubleLeft'
        val=coder.internal.indexInt(-1);
    case 'DoubleRight'
        val=coder.internal.indexInt(1);
    end

end