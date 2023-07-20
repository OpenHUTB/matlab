function val=ID(objtype)














%#codegen

    coder.allowpcode('plain');


    switch objtype
    case 'FEASIBLE'
        val=coder.internal.indexInt(1);
    case 'LINEAR'
        val=coder.internal.indexInt(2);
    case 'QUADRATIC'
        val=coder.internal.indexInt(3);
    case 'REGULARIZED'
        val=coder.internal.indexInt(4);
    case 'PHASEONE'
        val=coder.internal.indexInt(5);
    otherwise
        assert(false,'Unexpected Objective ID');
    end

end

