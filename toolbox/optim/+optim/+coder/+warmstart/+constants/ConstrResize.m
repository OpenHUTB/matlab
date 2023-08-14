function val=ConstrResize(constr_type)














%#codegen

    coder.allowpcode('plain');

    coder.internal.prefer_const(constr_type);

    switch(constr_type)
    case 'LinearIneq'
        val=coder.internal.indexInt(50);
    case 'LinearEq'
        val=coder.internal.indexInt(25);
    otherwise
        assert(false,'Unsupported constraint type.');
    end