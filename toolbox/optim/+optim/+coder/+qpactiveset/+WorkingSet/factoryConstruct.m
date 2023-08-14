function obj=factoryConstruct(mIneqMax,mEqMax,nVar,nVarMax,mConstrMax)








































%#codegen

    coder.allowpcode('plain');




    validateattributes(mIneqMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mEqMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nVarMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstrMax,{coder.internal.indexIntClass},{'scalar'});





    coder.internal.prefer_const(mIneqMax,mEqMax,nVar,nVarMax,mConstrMax);




    obj=struct();





    obj.mConstr=coder.internal.indexInt(0);
    obj.mConstrOrig=coder.internal.indexInt(0);
    obj.mConstrMax=mConstrMax;
    obj.nVar=nVar;
    obj.nVarOrig=nVar;
    obj.nVarMax=nVarMax;



    obj.ldA=coder.internal.indexInt(nVarMax);








    obj.Aineq=coder.nullcopy(realmax*ones(mIneqMax*nVarMax,1,'double'));
    obj.bineq=coder.nullcopy(realmax*ones(mIneqMax,1,'double'));

    obj.Aeq=coder.nullcopy(realmax*ones(mEqMax*nVarMax,1,'double'));
    obj.beq=coder.nullcopy(realmax*ones(mEqMax,1,'double'));

    obj.lb=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
    obj.ub=coder.nullcopy(realmax*ones(nVarMax,1,'double'));


    obj.indexLB=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(nVarMax,1,coder.internal.indexIntClass));
    obj.indexUB=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(nVarMax,1,coder.internal.indexIntClass));
    obj.indexFixed=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(nVarMax,1,coder.internal.indexIntClass));



    obj.mEqRemoved=coder.internal.indexInt(0);
    obj.indexEqRemoved=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(mEqMax,1,coder.internal.indexIntClass));



    obj.ATwset=coder.nullcopy(realmax*ones(nVarMax*mConstrMax,1,'double'));
    obj.bwset=coder.nullcopy(realmax*ones(mConstrMax,1,'double'));
    obj.nActiveConstr=coder.internal.indexInt(0);




    obj.maxConstrWorkspace=coder.nullcopy(realmax*ones(mConstrMax,1,'double'));






    obj.sizes=zeros(5,1,coder.internal.indexIntClass);
    obj.sizesNormal=zeros(5,1,coder.internal.indexIntClass);
    obj.sizesPhaseOne=zeros(5,1,coder.internal.indexIntClass);
    obj.sizesRegularized=zeros(5,1,coder.internal.indexIntClass);
    obj.sizesRegPhaseOne=zeros(5,1,coder.internal.indexIntClass);








    obj.isActiveIdx=zeros(6,1,coder.internal.indexIntClass);
    obj.isActiveIdxNormal=zeros(6,1,coder.internal.indexIntClass);
    obj.isActiveIdxPhaseOne=zeros(6,1,coder.internal.indexIntClass);
    obj.isActiveIdxRegularized=zeros(6,1,coder.internal.indexIntClass);
    obj.isActiveIdxRegPhaseOne=zeros(6,1,coder.internal.indexIntClass);









    obj.isActiveConstr=coder.nullcopy(false(mConstrMax,1));











    obj.Wid=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(mConstrMax,1,coder.internal.indexIntClass));
    obj.Wlocalidx=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(mConstrMax,1,coder.internal.indexIntClass));











    obj.nWConstr=zeros(5,1,coder.internal.indexIntClass);



    obj.probType=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));





    obj.SLACK0=coder.const(optim.coder.qpactiveset.constants.WorkingSetTolerances('Slack0'));





































end
