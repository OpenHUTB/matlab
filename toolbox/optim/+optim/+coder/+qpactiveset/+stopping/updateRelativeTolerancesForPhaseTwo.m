function tol=updateRelativeTolerancesForPhaseTwo(tol,H,f)






%#codegen

    coder.allowpcode('plain');

    validateattributes(tol,{'double'},{'scalar'});
    validateattributes(H,{'double'},{'2d','square','nonempty'});
    validateattributes(f,{'double'},{'2d'});

    INT_ONE=coder.internal.indexInt(1);
    H_infnrm=0.0;
    f_infnrm=0.0;

    if~isempty(f)
        for idx_col=INT_ONE:size(H,2)
            colSum=0.0;
            for idx_row=INT_ONE:size(H,1)
                colSum=colSum+abs(H(idx_row,idx_col));
            end
            H_infnrm=max(H_infnrm,colSum);
            f_infnrm=max(f_infnrm,abs(f(idx_col)));
        end
    else
        for idx_col=INT_ONE:size(H,2)
            colSum=0.0;
            for idx_row=INT_ONE:size(H,1)
                colSum=colSum+abs(H(idx_row,idx_col));
            end
            H_infnrm=max(H_infnrm,colSum);
        end
    end

    tol=max(tol,f_infnrm);
    tol=max(tol,H_infnrm);
    tol=max(1.0,tol);

end

