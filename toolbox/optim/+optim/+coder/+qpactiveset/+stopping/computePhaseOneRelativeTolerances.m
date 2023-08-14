function tol=computePhaseOneRelativeTolerances(workingset)






%#codegen

    coder.allowpcode('plain');

    validateattributes(workingset,{'struct'},{'scalar'});

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));




    INT_ONE=coder.internal.indexInt(1);
    nVarOrig=workingset.nVarOrig;
    tol=1.0;


    for idx_col=1:workingset.sizes(AEQ)
        colSum=0.0;
        colPos=workingset.ldA*(idx_col-INT_ONE);
        for idx_row=INT_ONE:nVarOrig
            idxPosAeq=idx_row+colPos;
            colSum=colSum+abs(workingset.Aeq(idxPosAeq));
        end
        tol=max(tol,colSum);
    end


    for idx_col=1:workingset.sizes(AINEQ)
        colSum=0.0;
        colPos=workingset.ldA*(idx_col-INT_ONE);
        for idx_row=INT_ONE:nVarOrig
            idxPosAineq=idx_row+colPos;
            colSum=colSum+abs(workingset.Aineq(idxPosAineq));
        end
        tol=max(tol,colSum);
    end













end