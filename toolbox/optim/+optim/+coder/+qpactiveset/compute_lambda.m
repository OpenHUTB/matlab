function[solution,workspace,objective,qrmanager]=...
    compute_lambda(H,workspace,solution,objective,qrmanager)








































%#codegen

    coder.allowpcode('plain');


    validateattributes(H,{'double'},{'2d'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});

    nVar=coder.internal.indexInt(qrmanager.mrows);
    nActiveConstr=coder.internal.indexInt(qrmanager.ncols);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);


    if(nActiveConstr<=INT_ZERO)
        return;
    end



    if(objective.objtype~=coder.const(optim.coder.qpactiveset.Objective.ID('REGULARIZED')))
        tolfactor=1e2;
        tol=tolfactor*double(nVar)*eps('double');
        nonDegenerate=optim.coder.QRManager.isNonDegenerate(qrmanager,tol);
        if~nonDegenerate
            solution.state=coder.const(optim.coder.SolutionState('DegenerateConstraints'));
            return;
        end
    end



    ldq=qrmanager.ldq;
    workspace=coder.internal.blas.xgemv('T',nVar,nActiveConstr,...
    1.0,qrmanager.Q,INT_ONE,ldq,objective.grad,INT_ONE,INT_ONE,0.0,workspace,INT_ONE,INT_ONE);


    workspace=coder.internal.blas.xtrsv('U','N','N',...
    nActiveConstr,qrmanager.QR,INT_ONE,ldq,workspace,INT_ONE,INT_ONE);


    for idx=1:nActiveConstr
        solution.lambda(idx)=-workspace(idx);
    end

end
