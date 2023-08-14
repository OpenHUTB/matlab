function[depIdx,qrmanager]=IndexOfDependentEq_(depIdx,mFixed,nDep,qrmanager,AeqfPrime,mRows,nCols,ldAeqfPrime)


















%#codegen

    coder.allowpcode('plain');






    validateattributes(depIdx,{coder.internal.indexIntClass},{'vector'});
    validateattributes(mFixed,{coder.internal.indexIntClass},{'vector'});
    validateattributes(nDep,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(mRows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nCols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldAeqfPrime,{coder.internal.indexIntClass},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);


    for idx=1:mFixed
        qrmanager.jpvt(idx)=INT_ONE;
    end
    for idx=mFixed+1:nCols
        qrmanager.jpvt(idx)=INT_ZERO;
    end


    qrmanager=optim.coder.QRManager.factorQRE(qrmanager,AeqfPrime,mRows,nCols,ldAeqfPrime);


    for idx=1:nDep
        depIdx(idx)=qrmanager.jpvt(nCols-nDep+idx);
    end

end
