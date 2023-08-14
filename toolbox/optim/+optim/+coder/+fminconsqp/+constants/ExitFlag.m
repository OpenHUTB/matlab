function val=ExitFlag(cname)














%#codegen

    coder.allowpcode('plain');

    switch cname
    case 'ObjectiveLimitReached'
        val=coder.internal.indexInt(-3);
    case 'Infeasible'
        val=coder.internal.indexInt(-2);
    case 'MaxIterOrFunReached'
        val=coder.internal.indexInt(0);
    case 'Optimal'
        val=coder.internal.indexInt(1);
    case 'Feasible'
        val=coder.internal.indexInt(2);
    otherwise
        assert(false,'fminconsqp.Constants.ExitFlag() unexpected input');
    end

end

