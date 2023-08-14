function[x,resnorm,residual,exitflag,output,lambda]=lsqlin(C,d,Aineq,bineq,Aeq,beq,lb,ub,x0,options)




























%#codegen


    coder.columnMajor;
    coder.allowpcode('plain');
    coder.internal.prefer_const(C,d,Aineq,bineq,Aeq,beq,lb,ub,x0,options);




    numOutputs=nargout();
    numInputs=nargin();

    INT_ONE=coder.internal.indexInt(1);


    optim.coder.validate.checkProducts();



    coder.internal.errorIf(numInputs==1&&isstruct(C),'optimlib_codegen:common:NoProbStructSupport');

    coder.internal.errorIf(numInputs<10,'optimlib_codegen:common:TooFewInputs','LSQLIN',10,'active-set');


    optim.coder.validate.checkOptions(options,'lsqlin','active-set');


    optim.coder.validate.checkQuadraticObjective(C,d,'C','d');


    coder.internal.errorIf(isempty(C),'optim_codegen:lsqlin:NullCMatrix');


    coder.internal.errorIf(abs(C(coder.internal.blas.ixamax(numel(C),C,INT_ONE,INT_ONE)))<eps('double'),...
    'optim_codegen:lsqlin:NullCMatrix');


    coder.internal.errorIf(~isempty(d)&&(numel(d)~=size(C,1)),'optimlib:lsqlin:InvalidCAndD');




    coder.internal.errorIf(isempty(x0),'optimlib_codegen:common:EmptyX');
    coder.internal.errorIf(size(C,2)~=numel(x0),'optim_codegen:lsqlin:InvalidSizesOfCAndX0');
    optim.coder.validate.checkX0(x0);


    nVar=coder.internal.indexInt(numel(x0));
    nVarMax=coder.internal.indexInt(nVar+INT_ONE);


    optim.coder.validate.checkLinearInputs(nVar,Aineq,bineq,Aeq,beq,lb,ub);




    C_rows=coder.internal.indexInt(size(C,1));
    C_cols=coder.internal.indexInt(size(C,2));


    H=coder.nullcopy(realmax*ones(C_cols,C_cols,'double'));
    H=coder.internal.blas.xgemm('T','N',C_cols,C_cols,C_rows,...
    1.0,C,INT_ONE,C_rows,C,INT_ONE,C_rows,0.0,H,INT_ONE,C_cols);


    f=coder.nullcopy(realmax*ones(C_cols,1,'double'));
    f=coder.internal.blas.xgemv('T',C_rows,C_cols,...
    -1.0,C,INT_ONE,C_rows,d,INT_ONE,INT_ONE,0.0,f,INT_ONE,INT_ONE);



    mIneq=coder.internal.indexInt(numel(bineq));
    mEq=coder.internal.indexInt(numel(beq));
    sizeLB=coder.internal.indexInt(numel(lb));
    sizeUB=coder.internal.indexInt(numel(ub));



    mConstrMax=coder.internal.indexInt(mIneq+mEq+sizeLB+sizeUB+1);





    solution.xstar=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
    solution.fstar=0.0;
    solution.firstorderopt=0.0;
    solution.lambda=zeros(mConstrMax,1,'double');
    solution.state=coder.internal.indexInt(0);
    solution.maxConstr=0.0;
    solution.iterations=coder.internal.indexInt(0);
    solution.searchDir=zeros(nVarMax,1,'double');


    solution.xstar=coder.internal.blas.xcopy(nVar,x0,INT_ONE,INT_ONE,solution.xstar,INT_ONE,INT_ONE);



    QPObjective=optim.coder.qpactiveset.Objective.factoryConstruct(nVarMax);
    QPObjective=optim.coder.qpactiveset.Objective.setQuadratic(QPObjective,~isempty(f),nVar);

    maxDims=max(nVarMax,mConstrMax);




    QRRowBound=nVar+max(INT_ONE,mEq);
    QRManager=optim.coder.QRManager.factoryConstruct(QRRowBound,maxDims);




    CholRegManager=optim.coder.DynamicRegCholManager.factoryConstruct(QRRowBound);




    CholRegManager.scaleFactor=1e2;





    WorkingSet=optim.coder.qpactiveset.WorkingSet.factoryConstruct(mIneq,mEq,nVar,nVarMax,mConstrMax);


    [WorkingSet.indexLB,mLB,WorkingSet.indexUB,mUB,WorkingSet.indexFixed,mFixed]=...
    optim.coder.qpactiveset.initialize.compressBounds(nVar,WorkingSet.indexLB,WorkingSet.indexUB,WorkingSet.indexFixed,lb,ub,...
    eml_option('NonFinitesSupport'),options.ConstraintTolerance);

    WorkingSet=optim.coder.qpactiveset.WorkingSet.loadProblem(WorkingSet,mIneq,mIneq,Aineq,bineq,...
    mEq,mEq,Aeq,beq,...
    mLB,lb,...
    mUB,ub,...
    mFixed,mConstrMax);

    QP_NORMAL_PROB_ID=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));
    WorkingSet=optim.coder.qpactiveset.WorkingSet.initActiveSet(WorkingSet,QP_NORMAL_PROB_ID);

    WorkingSet.SLACK0=0.0;




    memspace.workspace_double=coder.nullcopy(realmax*ones(maxDims,max(2,nVarMax),'double'));
    memspace.workspace_int=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(maxDims,1,coder.internal.indexIntClass));
    memspace.workspace_sort=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(maxDims,1,coder.internal.indexIntClass));


    runTimeOptions=optim.coder.options.convertQuadprogOptionsForSolver(options,nVar,mFixed+mEq+mIneq+mLB+mUB);




    runTimeOptions.ConstrRelTolFactor(:)=...
    optim.coder.qpactiveset.stopping.computePhaseOneRelativeTolerances(WorkingSet);


    runTimeOptions.ProbRelTolFactor(:)=...
    optim.coder.qpactiveset.stopping.updateRelativeTolerancesForPhaseTwo(runTimeOptions.ConstrRelTolFactor,H,f);


    [solution,memspace,WorkingSet,QRManager,CholRegManager,QPObjective]=...
    optim.coder.qpactiveset.driver(H,f,solution,memspace,WorkingSet,QRManager,CholRegManager,QPObjective,...
    options,runTimeOptions);%#ok<ASGLU>


    x=coder.nullcopy(realmax*ones(size(x0),'double'));
    x=coder.internal.blas.xcopy(nVar,solution.xstar,INT_ONE,INT_ONE,x,INT_ONE,INT_ONE);

    if(numOutputs>=2)







        residual=coder.nullcopy(realmax*ones(C_rows,1,'double'));
        residual=coder.internal.blas.xcopy(C_rows,d,INT_ONE,INT_ONE,residual,INT_ONE,INT_ONE);
        residual=coder.internal.blas.xgemv('N',C_rows,C_cols,...
        1.0,C,INT_ONE,C_rows,x,INT_ONE,INT_ONE,-1.0,residual,INT_ONE,INT_ONE);


        resnorm=coder.internal.blas.xdot(C_rows,residual,INT_ONE,INT_ONE,residual,INT_ONE,INT_ONE);

        if(numOutputs>=4)
            solution=optim.coder.qpactiveset.parseoutput.mapExitFlags(solution);
            exitflag=double(solution.state);

            if(numOutputs>=5)





                INFEASIBLE=coder.const(optim.coder.SolutionState('Infeasible'));
                if(solution.state==INFEASIBLE)
                    solution.firstorderopt=coder.internal.inf;
                elseif(solution.state<=0)










                    [solution.maxConstr,WorkingSet]=...
                    optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(WorkingSet,solution.xstar,INT_ONE);

                    if(solution.maxConstr<=options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor)

                        QPObjective=optim.coder.qpactiveset.Objective.computeGrad(QPObjective,H,f,solution.xstar);
                        [solution,QPObjective,memspace.workspace_double]=...
                        optim.coder.qpactiveset.parseoutput.computeFirstOrderOpt(solution,QPObjective,WorkingSet,...
                        memspace.workspace_double);%#ok<ASGLU>
                    else
                        solution.firstorderopt=coder.internal.inf;
                    end
                end





                output=struct('algorithm','active-set',...
                'firstorderopt',solution.firstorderopt,...
                'constrviolation',max(0.0,solution.maxConstr),...
                'iterations',double(solution.iterations));
                if(numOutputs>=6)






                    lambda=struct('ineqlin',zeros(mIneq,1,'double'),...
                    'eqlin',zeros(mEq,1,'double'),...
                    'lower',zeros(nVar,1,'double'),...
                    'upper',zeros(nVar,1,'double'));



                    if(WorkingSet.nActiveConstr>0)
                        [solution.lambda,memspace.workspace_double]=...
                        optim.coder.qpactiveset.parseoutput.sortLambdaQP...
                        (solution.lambda,WorkingSet,memspace.workspace_double,INT_ONE);

                        lambda=optim.coder.qpactiveset.parseoutput.dealLambdaIntoStruct(lambda,solution,WorkingSet);
                    end
                end
            end
        end
    end

end
