function[is_depcol,i2d,pinv]=ne_indcols_lu_c(A)







    [T,pinv]=nem_sparse_depcols(A,8*eps);








    is_depcol=any(T,1);
    is_pivrow=(pinv~=-1);
    if any(is_depcol)
        i2d_est=T(~is_depcol,is_depcol);
        r=A(is_pivrow,~is_depcol)*i2d_est-A(is_pivrow,is_depcol);











        [lastWarnMsg,lastWarnId]=lastwarn;
        lastwarn('');
        smw=warning('off','MATLAB:singularMatrix');
        nsmw=warning('off','MATLAB:nearlySingularMatrix');
        del=A(is_pivrow,~is_depcol)\r;
        [~,solveWarnId]=lastwarn;
        if strcmp(solveWarnId,'MATLAB:singularMatrix')
            is_depcol=false(size(is_depcol));
            i2d=sparse(size(A,2),0);
        else
            i2d=i2d_est-del;
            i2d(abs(i2d)<1e-22)=0;
            i2d(abs(i2d)<1e-6*abs(i2d_est))=0;
        end

        lastwarn(lastWarnMsg,lastWarnId);
        warning(smw);
        warning(nsmw);
    else
        i2d=T(~is_depcol,is_depcol);
    end
