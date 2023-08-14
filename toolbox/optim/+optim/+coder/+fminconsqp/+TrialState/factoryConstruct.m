function obj=factoryConstruct(nVarMax,mConstrMax,mIneq,mEq,x0,mNonlinIneq,mNonlinEq)

































%#codegen

    coder.allowpcode('plain');


    validateattributes(nVarMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstrMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVarMax,mConstrMax,mIneq,mEq,mNonlinIneq,mNonlinEq);

    obj=struct();




    obj.nVarMax=nVarMax;
    obj.mNonlinIneq=mNonlinIneq;
    obj.mNonlinEq=mNonlinEq;
    obj.mIneq=mIneq;
    obj.mEq=mEq;
    obj.iNonIneq0=mIneq-mNonlinIneq+1;
    obj.iNonEq0=mEq-mNonlinEq+1;


    obj.sqpFval=0.0;
    obj.sqpFval_old=0.0;


    obj.xstarsqp=coder.nullcopy(realmax*ones(size(x0),'double'));
    obj.xstarsqp_old=coder.nullcopy(realmax*ones(size(x0),'double'));


    obj.cIneq=coder.nullcopy(realmax*ones(mIneq,1,'double'));
    obj.cIneq_old=coder.nullcopy(realmax*ones(mIneq,1,'double'));


    obj.cEq=coder.nullcopy(realmax*ones(mEq,1,'double'));
    obj.cEq_old=coder.nullcopy(realmax*ones(mEq,1,'double'));



    obj.grad=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
    obj.grad_old=coder.nullcopy(realmax*ones(nVarMax,1,'double'));


    obj.FunctionEvaluations=coder.internal.indexInt(0);
    obj.sqpIterations=coder.internal.indexInt(0);
    obj.sqpExitFlag=coder.internal.indexInt(0);



    obj.lambdasqp=zeros(mConstrMax,1,'double');






    obj.lambdaStopTest=coder.nullcopy(realmax*ones(mConstrMax,1,'double'));
    obj.lambdaStopTestPrev=coder.nullcopy(realmax*ones(mConstrMax,1,'double'));


    obj.steplength=1.0;
    obj.delta_x=zeros(nVarMax,1,'double');
    obj.socDirection=coder.nullcopy(realmax*ones(nVarMax,1,'double'));






    obj.workingset_old=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(mConstrMax,1,coder.internal.indexIntClass));







    if(mNonlinIneq>0)
        obj.JacCineqTrans_old=coder.nullcopy(realmax*ones(nVarMax,mNonlinIneq,'double'));
    else
        obj.JacCineqTrans_old=[];
    end

    if(mNonlinEq>0)
        obj.JacCeqTrans_old=coder.nullcopy(realmax*ones(nVarMax,mNonlinEq,'double'));
    else
        obj.JacCeqTrans_old=[];
    end



    obj.gradLag=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
    obj.delta_gradLag=coder.nullcopy(realmax*ones(nVarMax,1,'double'));



    obj.xstar=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
    obj.fstar=0.0;
    obj.firstorderopt=0.0;
    obj.lambda=zeros(mConstrMax,1,'double');
    obj.state=coder.internal.indexInt(0);
    obj.maxConstr=0.0;
    obj.iterations=coder.internal.indexInt(0);
    obj.searchDir=coder.nullcopy(realmax*ones(nVarMax,1,'double'));










end
