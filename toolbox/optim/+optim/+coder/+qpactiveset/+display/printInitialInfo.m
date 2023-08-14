function printInitialInfo(PROBLEM_TYPE,solution,workingset)












%#codegen

    coder.allowpcode('plain');

    validateattributes(PROBLEM_TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});


    PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('PHASEONE'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'));
    REGULARIZED_PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED_PHASEONE'));

    switch PROBLEM_TYPE
    case PHASEONE
        stepType_str='Phase One    ';
    case REGULARIZED
        stepType_str='Regularized  ';
    case REGULARIZED_PHASEONE
        stepType_str='Phase One Reg';
    otherwise
        stepType_str='Normal       ';
    end


    fprintf(['%5i  %14.6e',blanks(92),'%5i    %s'],...
    solution.iterations,solution.fstar,workingset.nActiveConstr,stepType_str);

    fprintf('\n');

end

