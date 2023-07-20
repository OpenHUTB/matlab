function[numDependent,qrmanager]=ComputeNumDependentEq_(qrmanager,Aeqf,beqf,mConstr,nVar,ldAeqf,tolfactor)































































%#codegen

    coder.allowpcode('plain');



    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(beqf,{'double'},{'vector'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstr,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldAeqf,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(tolfactor,{'double'},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    numDependent=coder.internal.indexInt(mConstr-nVar);
    numDependent=max(INT_ZERO,numDependent);

    for idx=1:nVar
        qrmanager.jpvt(idx)=INT_ZERO;
    end


    qrmanager=optim.coder.QRManager.factorQRE(qrmanager,Aeqf,mConstr,nVar,ldAeqf);


    tol=tolfactor*double(nVar)*eps('double');

    totalRank=min(nVar,mConstr);




    idxDiag=totalRank+qrmanager.ldq*(totalRank-INT_ONE);
    while(idxDiag>0&&abs(qrmanager.QR(idxDiag))<tol)
        idxDiag=idxDiag-qrmanager.ldq-INT_ONE;
        numDependent=numDependent+1;
    end


    if(numDependent>0)



        qrmanager=optim.coder.QRManager.computeSquareQ(qrmanager);

        for idx=1:numDependent
            iQ0=1+qrmanager.ldq*(mConstr-idx);
            qtb=coder.internal.blas.xdot(mConstr,qrmanager.Q,iQ0,INT_ONE,beqf,INT_ONE,INT_ONE);

            if(abs(qtb)>=tol)
                numDependent(:)=-1;
                break;
            end
        end
    end

end
