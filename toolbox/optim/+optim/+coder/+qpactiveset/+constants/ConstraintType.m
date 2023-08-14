function val=ConstraintType(constrType)















%#codegen

    coder.allowpcode('plain');

    switch constrType
    case 'PHASEONE'
        val=coder.internal.indexInt(1);
    case 'REGULARIZED'
        val=coder.internal.indexInt(2);
    case 'NORMAL'
        val=coder.internal.indexInt(3);
    case 'REGULARIZED_PHASEONE'
        val=coder.internal.indexInt(4);
    otherwise
        assert(false,'qpactiveset_ConstraintType unexpected input');
    end

end

