function[solution,memspace,workingset,qrmanager,cholmanager]=...
    resizeDataStructs(mEqMax,mIneqMax,mConstrMax,QRRowBound,memspaceIntBnd,memspaceDblBnd,...
    solution,memspace,workingset,qrmanager,cholmanager)



















%#codegen

    coder.allowpcode('plain');

    validateattributes(mEqMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneqMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstrMax,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(QRRowBound,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(memspaceIntBnd,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(memspaceDblBnd,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(cholmanager,{'struct'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);
    nVarMax=coder.internal.indexInt(numel(solution.xstar));
    maxDims=max(nVarMax,mConstrMax);


    if(numel(solution.lambda)<mConstrMax)
        solution.lambda=zeros(mConstrMax,1,'double');
    end


    if(size(memspace.workspace_double,1)<maxDims||size(memspace.workspace_double,2)<max(2,nVarMax))
        memspace.workspace_double=coder.nullcopy(realmax*ones(maxDims,max(2,nVarMax),'double'));
    end

    if(numel(memspace.workspace_int)<memspaceIntBnd)
        memspace.workspace_int=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(memspaceIntBnd,1,coder.internal.indexIntClass));
        memspace.workspace_sort=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(memspaceIntBnd,1,coder.internal.indexIntClass));
    end

    if(numel(memspace.workspace_compareIneq)<memspaceDblBnd)
        memspace.workspace_compareIneq=coder.nullcopy(realmax*ones(memspaceDblBnd,1,'double'));
    end





    if(numel(workingset.bineq)<mIneqMax)
        [workingset.Aineq,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.Aineq,memspace.workspace_compareIneq,mIneqMax*nVarMax,INT_ONE);
        [workingset.bineq,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.bineq,memspace.workspace_compareIneq,mIneqMax,INT_ONE);
    end

    if(numel(workingset.beq)<mEqMax)
        [workingset.Aeq,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.Aeq,memspace.workspace_compareIneq,mEqMax*nVarMax,INT_ONE);
        [workingset.beq,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.beq,memspace.workspace_compareIneq,mEqMax,INT_ONE);
        [workingset.indexEqRemoved,memspace.workspace_int]=expandWorkingSetArrayInt(workingset.indexEqRemoved,memspace.workspace_int,mEqMax,INT_ONE);
    end

    if(numel(workingset.bwset)<mConstrMax)
        workingset.mConstrMax(:)=mConstrMax;
        [workingset.ATwset,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.ATwset,memspace.workspace_compareIneq,mConstrMax*nVarMax,INT_ONE);
        [workingset.bwset,memspace.workspace_compareIneq]=expandWorkingSetArrayDouble(workingset.bwset,memspace.workspace_compareIneq,mConstrMax,INT_ONE);
        workingset.maxConstrWorkspace=coder.nullcopy(realmax*ones(mConstrMax,INT_ONE,'double'));
        [workingset.isActiveConstr,memspace.workspace_int]=expandWorkingSetArrayInt(workingset.isActiveConstr,memspace.workspace_int,mConstrMax,INT_ONE);
        [workingset.Wid,memspace.workspace_int]=expandWorkingSetArrayInt(workingset.Wid,memspace.workspace_int,mConstrMax,INT_ONE);
        [workingset.Wlocalidx,memspace.workspace_int]=expandWorkingSetArrayInt(workingset.Wlocalidx,memspace.workspace_int,mConstrMax,INT_ONE);
    end







    if(numel(qrmanager.Q)<QRRowBound*QRRowBound)
        qrmanager.ldq(:)=QRRowBound;
        qrmanager.Q=zeros(QRRowBound,QRRowBound,'double');
    end

    Qbound=coder.internal.indexInt(size(qrmanager.Q,1));

    if(size(qrmanager.QR,1)<Qbound||size(qrmanager.QR,2)<maxDims)
        qrmanager.QR=coder.nullcopy(realmax*ones(Qbound,maxDims,'double'));
    end

    if(numel(qrmanager.jpvt)<maxDims)
        qrmanager.jpvt=zeros(maxDims,1,coder.internal.indexIntClass);
    end

    minRowCol=min(Qbound,maxDims);
    if(numel(qrmanager.tau)<minRowCol)
        qrmanager.tau=coder.nullcopy(realmax*ones(minRowCol,1,'double'));
    end



    BLOCK_SIZE=coder.const(optim.coder.DynamicRegCholManager.Constants('BlockSizeL3BLAS'));
    cholmanager.ldm(:)=QRRowBound;
    if(numel(cholmanager.FMat)<QRRowBound*QRRowBound)
        cholmanager.FMat=coder.nullcopy(realmax*ones(QRRowBound*QRRowBound,1,'double'));
        cholmanager.workspace_=coder.nullcopy(realmax*ones(BLOCK_SIZE*QRRowBound,1,'double'));
        cholmanager.workspace2_=coder.nullcopy(realmax*ones(BLOCK_SIZE*QRRowBound,1,'double'));
    end

end

function[X,workspace]=expandWorkingSetArrayDouble(X,workspace,newRows,newCols)
    coder.inline('always');

    validateattributes(X,{'double'},{'2d'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(newRows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(newCols,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);
    numelX=coder.internal.indexInt(numel(X));


    workspace=coder.internal.blas.xcopy(numelX,X,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);



    X=zeros(newRows,newCols,'double');


    X=coder.internal.blas.xcopy(numelX,workspace,INT_ONE,INT_ONE,X,INT_ONE,INT_ONE);

end

function[X,workspace]=expandWorkingSetArrayInt(X,workspace,newRows,newCols)

    coder.inline('always');

    validateattributes(X,{coder.internal.indexIntClass,'logical'},{'2d'});
    validateattributes(workspace,{coder.internal.indexIntClass},{'2d'});
    validateattributes(newRows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(newCols,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);
    numelX=coder.internal.indexInt(numel(X));


    for idx=INT_ONE:numelX
        workspace(idx)=X(idx);
    end


    X=coder.nullcopy(zeros(newRows,newCols,'like',X));


    for idx=INT_ONE:numelX
        X(idx)=workspace(idx);
    end

end

