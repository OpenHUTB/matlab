function printInfo(newBlocking,PROBLEM_TYPE,alpha,stepNorm,...
    activeConstrChangedType,localActiveConstrIdx,activeSetChangeID,solution,workingset)
















%#codegen

    coder.allowpcode('plain');

    validateattributes(newBlocking,{'logical'},{'scalar'});
    validateattributes(PROBLEM_TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(alpha,{'double'},{'scalar'});
    validateattributes(stepNorm,{'double'},{'scalar'});
    validateattributes(activeConstrChangedType,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(localActiveConstrIdx,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(activeSetChangeID,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});


    PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('PHASEONE'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'));
    REGULARIZED_PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED_PHASEONE'));


    fprintf('%5i  %14.6e  %14.6e  %14.6e',solution.iterations,solution.fstar,solution.firstorderopt,solution.maxConstr);


    fprintf(blanks(2));


    if isnan(alpha)
        fprintf('       -      ');
    else
        fprintf('%14.6e',alpha);
    end


    fprintf(blanks(2));


    fprintf('%14.6e',stepNorm);


    fprintf(blanks(4));


    if(newBlocking||activeSetChangeID==CONSTR_DELETED)
        if(newBlocking)
            activeSetChangeID=CONSTR_ADDED;
        end
        workingSetAction(activeConstrChangedType,localActiveConstrIdx,activeSetChangeID,workingset);
    else
        fprintf(' SAME ');
        fprintf('(%-5i)',coder.internal.indexInt(-1));
    end


    fprintf(blanks(11));


    fprintf('%5i',workingset.nActiveConstr);


    fprintf(blanks(4));

    switch PROBLEM_TYPE
    case PHASEONE
        fprintf('Phase One');
    case REGULARIZED
        fprintf('Regularized');
    case REGULARIZED_PHASEONE
        fprintf('Phase One Reg');
    otherwise
        fprintf('Normal');
    end

    fprintf('\n');

end

function workingSetAction(activeConstrChangedType,localActiveConstrIdx,activeSetChangeID,workingset)

    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));



    switch activeSetChangeID
    case CONSTR_DELETED
        fprintf('-');
    case CONSTR_ADDED
        fprintf('+');
    otherwise
        fprintf(' ');
    end


    switch activeConstrChangedType
    case AINEQ
        fprintf('AINEQ');
    case LOWER
        fprintf('LOWER');

        localActiveConstrIdx=workingset.indexLB(localActiveConstrIdx);
    case UPPER
        fprintf('UPPER');

        localActiveConstrIdx=workingset.indexUB(localActiveConstrIdx);
    otherwise
        fprintf('SAME ');
        localActiveConstrIdx=coder.internal.indexInt(-1);
    end


    fprintf('(%-5i)',localActiveConstrIdx);

end

function formulaType=CONSTR_DELETED
    coder.inline('always');
    formulaType=coder.internal.indexInt(-1);
end

function formulaType=CONSTR_ADDED
    coder.inline('always');
    formulaType=coder.internal.indexInt(1);
end
