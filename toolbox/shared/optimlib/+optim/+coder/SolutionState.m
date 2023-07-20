function val=SolutionState(cname)














%#codegen

    coder.allowpcode('plain');

    switch cname


    case 'UndefinedStep'
        val=coder.internal.indexInt(-8);
    case 'DegenerateConstraints'
        val=coder.internal.indexInt(-7);
    case 'IndefiniteQP'
        val=coder.internal.indexInt(-6);
    case 'StartContinue'
        val=coder.internal.indexInt(-5);
    case 'InconsistentEq'
        val=coder.internal.indexInt(-3);
    case 'Infeasible'
        val=coder.internal.indexInt(-2);


    case 'MaxIterReached'
        val=coder.internal.indexInt(0);
    case 'Optimal'
        val=coder.internal.indexInt(1);
    case 'ObjectiveLimitReached'
        val=coder.internal.indexInt(2);
    case 'Unbounded'
        val=coder.internal.indexInt(3);
    case 'IllPosed'
        val=coder.internal.indexInt(4);
    case 'NonOptimal'
        val=coder.internal.indexInt(5);










    case 'PrimalFeasible'
        val=coder.internal.indexInt(82);






    end

end

