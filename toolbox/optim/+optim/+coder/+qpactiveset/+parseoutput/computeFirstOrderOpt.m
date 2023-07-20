function[solution,objective,workspace]=...
    computeFirstOrderOpt(solution,objective,workingset,workspace)
























%#codegen

    coder.allowpcode('plain');

    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});

    INT_ONE=coder.internal.indexInt(1);

    nVar=coder.internal.indexInt(workingset.nVar);
    nActiveConstr=coder.internal.indexInt(workingset.nActiveConstr);
    ldw=coder.internal.indexInt(workingset.ldA);


    workspace=coder.internal.blas.xcopy(nVar,objective.grad,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);


    workspace=coder.internal.blas.xgemv('N',nVar,nActiveConstr,...
    1.0,workingset.ATwset,INT_ONE,ldw,solution.lambda,INT_ONE,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);


    idxmax=coder.internal.blas.ixamax(nVar,workspace,INT_ONE,INT_ONE);
    solution.firstorderopt=abs(workspace(idxmax));

end

