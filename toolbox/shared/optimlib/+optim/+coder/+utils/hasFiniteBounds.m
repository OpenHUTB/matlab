function[hasLB,hasUB,hasBounds]=hasFiniteBounds(nvar,hasLB,hasUB,lb,ub,options)























%#codegen

    coder.allowpcode('plain');


    validateattributes(nvar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(hasLB,{'logical'},{'vector'});
    validateattributes(hasUB,{'logical'},{'vector'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(options,{'struct'},{'scalar'});

    coder.internal.prefer_const(nvar,options);

    hasBounds=false;
    idx=coder.internal.indexInt(1);

    emptyUB=bitshift(uint32(isempty(ub)),1,'uint32');
    emptyLB=uint32(isempty(lb));





    switch bitor(emptyUB,emptyLB,'uint32')
    case uint32(0)
        while(~hasBounds&&idx<=nvar)
            hasLB(idx)=optim.coder.utils.isFiniteLB(lb(idx));
            hasUB(idx)=optim.coder.utils.isFiniteUB(ub(idx));
            hasBounds=(hasLB(idx)||hasUB(idx));
            idx=idx+1;
        end
        while(idx<=nvar)
            hasLB(idx)=optim.coder.utils.isFiniteLB(lb(idx));
            hasUB(idx)=optim.coder.utils.isFiniteUB(ub(idx));
            idx=idx+1;
        end
    case uint32(1)
        while(~hasBounds&&idx<=nvar)
            hasLB(idx)=false;
            hasUB(idx)=optim.coder.utils.isFiniteUB(ub(idx));
            hasBounds=hasUB(idx);
            idx=idx+1;
        end
        while(idx<=nvar)
            hasLB(idx)=false;
            hasUB(idx)=optim.coder.utils.isFiniteUB(ub(idx));
            idx=idx+1;
        end
    case uint32(2)
        while(~hasBounds&&idx<=nvar)
            hasLB(idx)=optim.coder.utils.isFiniteLB(lb(idx));
            hasUB(idx)=false;
            hasBounds=hasLB(idx);
            idx=idx+1;
        end
        while(idx<=nvar)
            hasLB(idx)=optim.coder.utils.isFiniteLB(lb(idx));
            hasUB(idx)=false;
            idx=idx+1;
        end
    otherwise
        for k=1:nvar
            hasLB(k)=false;
            hasUB(k)=false;
        end
    end

end