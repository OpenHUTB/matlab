function[xCurrent,nonDegenerateWset,workspace,workingset,qrmanager]=...
    feasibleX0ForWorkingSet(workspace,xCurrent,workingset,qrmanager)































%#codegen

    coder.allowpcode('plain');


    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(xCurrent,{'double'},{'vector'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});


    INT_ONE=coder.internal.indexInt(1);

    mWConstr=coder.internal.indexInt(workingset.nActiveConstr);
    nVar=coder.internal.indexInt(workingset.nVar);
    nonDegenerateWset=true;

    if(mWConstr==0)
        return;
    end



    for idx=1:mWConstr
        workspace(idx,1)=workingset.bwset(idx);
        workspace(idx,2)=workingset.bwset(idx);
    end



    workspace=coder.internal.blas.xgemv('T',nVar,mWConstr,-1.0,workingset.ATwset,INT_ONE,workingset.ldA,...
    xCurrent,INT_ONE,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);








    if(mWConstr>=nVar)



        for idx_col=1:nVar
            offsetQR=qrmanager.ldq*(idx_col-INT_ONE);
            for idx_row=1:mWConstr
                idxQR=idx_row+offsetQR;
                idxATw=idx_col+workingset.ldA*(idx_row-INT_ONE);
                qrmanager.QR(idxQR)=workingset.ATwset(idxATw);
            end
        end

        qrmanager=optim.coder.QRManager.factorQR(qrmanager,[],mWConstr,nVar,workingset.ldA);
        qrmanager=optim.coder.QRManager.computeSquareQ(qrmanager);


        ldq=qrmanager.ldq;
        ldw=coder.internal.indexInt(size(workspace,1));
        workspace=coder.internal.blas.xgemm('T','N',nVar,2,mWConstr,...
        1.0,qrmanager.Q,INT_ONE,ldq,workspace,INT_ONE,ldw,0.0,workspace,INT_ONE,ldw);


        workspace=coder.internal.blas.xtrsm('L','U','N','N',...
        nVar,2,1.0,qrmanager.QR,INT_ONE,ldq,workspace,INT_ONE,ldw);

    else



        qrmanager=optim.coder.QRManager.factorQR(qrmanager,workingset.ATwset,nVar,mWConstr,workingset.ldA);
        qrmanager=optim.coder.QRManager.computeTallQ(qrmanager);


        ldq=qrmanager.ldq;
        ldw=coder.internal.indexInt(size(workspace,1));
        workspace=coder.internal.blas.xtrsm('L','U','T','N',...
        mWConstr,2,1.0,qrmanager.QR,INT_ONE,ldq,workspace,INT_ONE,ldw);


        workspace=coder.internal.blas.xgemm('N','N',nVar,2,mWConstr,...
        1.0,qrmanager.Q,INT_ONE,ldq,workspace,INT_ONE,ldw,0.0,workspace,INT_ONE,ldw);

    end


    for idx=1:nVar
        if~optim.coder.utils.isFiniteScalar(workspace(idx,1))||~optim.coder.utils.isFiniteScalar(workspace(idx,2))
            nonDegenerateWset=false;
            return;
        end
    end






    workspace=coder.internal.blas.xaxpy(nVar,1.0,xCurrent,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);

    ix0_1=coder.internal.indexInt(1);
    ix0_2=ix0_1+coder.internal.indexInt(size(workspace,1));



    [constrViolation_minnormX,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,workspace,ix0_1);
    [constrViolation_basicX,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,workspace,ix0_2);

    if(constrViolation_minnormX<=eps('double')||constrViolation_minnormX<constrViolation_basicX)

        xCurrent=coder.internal.blas.xcopy(nVar,workspace,ix0_1,INT_ONE,xCurrent,INT_ONE,INT_ONE);
    else

        xCurrent=coder.internal.blas.xcopy(nVar,workspace,ix0_2,INT_ONE,xCurrent,INT_ONE,INT_ONE);
    end

end
