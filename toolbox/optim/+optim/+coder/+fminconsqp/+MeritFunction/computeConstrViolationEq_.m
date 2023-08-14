function normResid=computeConstrViolationEq_(mEq,eq_workspace,ieq0)












%#codegen

    coder.allowpcode('plain');


    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(eq_workspace,{'double'},{'2d'});
    validateattributes(ieq0,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(mEq,ieq0);


    normResid=coder.internal.blas.xasum(mEq,eq_workspace,ieq0,INT_ONE);

end

function formulaType=INT_ONE
    coder.inline('always');
    formulaType=coder.internal.indexInt(1);
end
