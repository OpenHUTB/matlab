function[xk,WorkingSet]=makeBoundFeasible(xk,WorkingSet,lb,ub,tolcon)
























%#codegen

    coder.allowpcode('plain');

    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(tolcon,{'double'},{'scalar'});


    coder.internal.prefer_const(lb,ub);

    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    mLB=WorkingSet.sizes(LOWER);
    mUB=WorkingSet.sizes(UPPER);


    if~isempty(lb)
        if isempty(ub)


            for idx=1:mLB
                idx_local=WorkingSet.indexLB(idx);
                if(-xk(idx_local)>WorkingSet.lb(idx_local))


                    xk(idx_local)=-WorkingSet.lb(idx_local)+abs(WorkingSet.lb(idx_local));
                end
            end
        else

            for idx=1:mLB
                idx_local=WorkingSet.indexLB(idx);
                if(-xk(idx_local)>WorkingSet.lb(idx_local))
                    if isinf(ub(idx_local))
                        xk(idx_local)=-WorkingSet.lb(idx_local)+abs(WorkingSet.lb(idx_local));
                    else


                        xk(idx_local)=(WorkingSet.ub(idx_local)-WorkingSet.lb(idx_local))/2;
                    end
                end
            end
        end
    end


    if~isempty(ub)
        if isempty(lb)


            for idx=1:mUB
                idx_local=WorkingSet.indexUB(idx);
                if(xk(idx_local)>WorkingSet.ub(idx_local))


                    xk(idx_local)=WorkingSet.ub(idx_local)-abs(WorkingSet.ub(idx_local));
                end
            end
        else

            for idx=1:mUB
                idx_local=WorkingSet.indexUB(idx);
                if(xk(idx_local)>WorkingSet.ub(idx_local))
                    if isinf(lb(idx_local))
                        xk(idx_local)=WorkingSet.ub(idx_local)-abs(WorkingSet.ub(idx_local));
                    else


                        xk(idx_local)=(WorkingSet.ub(idx_local)-WorkingSet.lb(idx_local))/2;
                    end
                end
            end
        end
    end



end

