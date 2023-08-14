function val=FiniteDifferenceType(cname)













%#codegen

    coder.allowpcode('plain');


    switch cname
    case 'FORWARD'
        val=coder.internal.indexInt(0);
    case 'CENTRAL'
        val=coder.internal.indexInt(1);
    end

end
