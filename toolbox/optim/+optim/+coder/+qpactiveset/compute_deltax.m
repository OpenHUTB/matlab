function[solution,memspace,qrmanager,cholmanager,objective]=...
    compute_deltax(H,solution,memspace,qrmanager,cholmanager,objective,alwaysPositiveDef)







































%#codegen

    coder.allowpcode('plain');


    validateattributes(H,{'double'},{'2d'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(alwaysPositiveDef,{'logical'},{'scalar'});

    coder.internal.prefer_const(alwaysPositiveDef);

    nVar=coder.internal.indexInt(qrmanager.mrows);
    mConstr=coder.internal.indexInt(qrmanager.ncols);
    mNull=coder.internal.indexInt(nVar-mConstr);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    QUADRATIC=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.Objective.ID('REGULARIZED'));


    [TYPE,objective]=optim.coder.qpactiveset.Objective.getObjectiveType(objective);



    if(mNull<=INT_ZERO)
        for idx=1:nVar
            solution.searchDir(idx)=0.0;
        end
        return;
    end


    for idx=1:nVar
        solution.searchDir(idx)=-objective.grad(idx);
    end





    if(mConstr<=0)
        switch TYPE
        case PHASEONE

        case QUADRATIC



            cholmanager=factor(cholmanager,H,nVar,nVar,alwaysPositiveDef);


            if(cholmanager.info~=coder.internal.lapack.info_t)
                solution.state=coder.const(optim.coder.SolutionState('IndefiniteQP'));
                return;
            end


            [solution.searchDir,cholmanager]=solve(cholmanager,solution.searchDir,alwaysPositiveDef);

        case REGULARIZED

            if(alwaysPositiveDef)









                nVarOrig=coder.internal.indexInt(objective.nvar);
                cholmanager=factor(cholmanager,H,nVarOrig,nVarOrig,alwaysPositiveDef);


                if(cholmanager.info~=coder.internal.lapack.info_t)
                    solution.state=coder.const(optim.coder.SolutionState('IndefiniteQP'));
                    return;
                end


                [solution.searchDir,cholmanager]=solve(cholmanager,solution.searchDir,alwaysPositiveDef);


                solution.searchDir=coder.internal.blas.xscal(nVar-nVarOrig,1/objective.beta,solution.searchDir,nVarOrig+1,INT_ONE);
            end
        end

        return;
    end




    nullStartIdx=coder.internal.indexInt(1+qrmanager.ldq*mConstr);



    switch TYPE
    case PHASEONE


        for idx=1:mNull
            idxQ=nVar+qrmanager.ldq*(mConstr+idx-INT_ONE);
            memspace.workspace_double(idx)=-qrmanager.Q(idxQ);
        end



        solution.searchDir=coder.internal.blas.xgemv('N',nVar,mNull,1.0,qrmanager.Q,nullStartIdx,qrmanager.ldq,...
        memspace.workspace_double,INT_ONE,INT_ONE,0.0,solution.searchDir,INT_ONE,INT_ONE);

        return;

    otherwise
        switch TYPE

        case QUADRATIC




            [cholmanager,qrmanager,memspace]=...
            optim.coder.qpactiveset.computeProjectedHessian(H,cholmanager,qrmanager,memspace);

        otherwise

            if(alwaysPositiveDef)

                nVarOrig=coder.internal.indexInt(objective.nvar);
                [cholmanager,qrmanager,memspace]=...
                optim.coder.fminconsqp.step.relaxed.computeProjectedHessian_regularized(objective.beta,H,nVarOrig,...
                cholmanager,qrmanager,memspace);
            end

        end


        cholmanager=factor(cholmanager,[],mNull,INT_ZERO,alwaysPositiveDef);


        if(cholmanager.info~=coder.internal.lapack.info_t)
            solution.state=coder.const(optim.coder.SolutionState('IndefiniteQP'));
            return;
        end


        memspace.workspace_double=coder.internal.blas.xgemv('T',nVar,mNull,-1.0,qrmanager.Q,nullStartIdx,qrmanager.ldq,...
        objective.grad,INT_ONE,INT_ONE,0.0,memspace.workspace_double,INT_ONE,INT_ONE);


        [memspace.workspace_double,cholmanager]=solve(cholmanager,memspace.workspace_double,alwaysPositiveDef);

    end



    solution.searchDir=coder.internal.blas.xgemv('N',nVar,mNull,1.0,qrmanager.Q,nullStartIdx,qrmanager.ldq,...
    memspace.workspace_double,INT_ONE,INT_ONE,0.0,solution.searchDir,INT_ONE,INT_ONE);

end




function cholmanager=factor(cholmanager,H,ndims,ldH,alwaysPositiveDef)
    coder.inline('always');

    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(H,{'double'},{'2d'});
    validateattributes(ndims,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldH,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(alwaysPositiveDef,{'logical'},{'scalar'});

    coder.internal.prefer_const(alwaysPositiveDef);


    if(alwaysPositiveDef)
        cholmanager=optim.coder.CholManager.factor(cholmanager,H,ndims,ldH);
    else
        cholmanager=optim.coder.DynamicRegCholManager.factor(cholmanager,H,ndims,ldH);
    end

end

function[rhs,cholmanager]=solve(cholmanager,rhs,alwaysPositiveDef)
    coder.inline('always');

    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(rhs,{'double'},{'2d'});
    validateattributes(alwaysPositiveDef,{'logical'},{'scalar'});

    coder.internal.prefer_const(alwaysPositiveDef);


    if(alwaysPositiveDef)
        [rhs,cholmanager]=optim.coder.CholManager.solve(cholmanager,rhs);
    else
        [rhs,cholmanager]=optim.coder.DynamicRegCholManager.solve(cholmanager,rhs);
    end

end
