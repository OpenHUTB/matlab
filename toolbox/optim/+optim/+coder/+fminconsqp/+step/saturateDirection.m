function[delta_x,xstarqp]=saturateDirection(xk,delta_x,xstarqp,indexLB,indexUB,mLB,mUB,lb,ub)

























%#codegen

    coder.allowpcode('plain');


    validateattributes(delta_x,{'double'},{'vector'});
    validateattributes(xstarqp,{'double'},{'vector'});
    validateattributes(indexLB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(indexUB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});

    coder.internal.prefer_const(indexUB,indexLB,mLB,mUB,lb,ub);


    if~isempty(lb)
        for idx=1:mLB
            idx_local=indexLB(idx);
            violationResid=xk(idx_local)+delta_x(idx_local)-lb(idx_local);
            if(violationResid<0.0)
                delta_x(idx_local)=delta_x(idx_local)-violationResid;
                xstarqp(idx_local)=xstarqp(idx_local)-violationResid;
            end
        end
    end


    if~isempty(ub)
        for idx=1:mUB
            idx_local=indexUB(idx);
            violationResid=ub(idx_local)-xk(idx_local)-delta_x(idx_local);
            if(violationResid<0.0)
                delta_x(idx_local)=delta_x(idx_local)+violationResid;
                xstarqp(idx_local)=xstarqp(idx_local)+violationResid;
            end
        end
    end

end

