function[dx,dxInfNorm]=projectBox(x,dx,lb,ub,hasLB,hasUB)


























%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(x,dx,lb,ub,hasLB,hasUB);




    validateattributes(lb,{'double'},{'column'});
    validateattributes(ub,{'double'},{'column'});
    validateattributes(hasLB,{'logical'},{'column'});
    validateattributes(hasUB,{'logical'},{'column'});

    n=coder.internal.indexInt(numel(dx));
    dxInfNorm=double(0);

    if isempty(x)
        for i=1:n
            if hasLB(i)&&numel(lb)>0
                dx(i)=max(lb(i),dx(i));
            end
            if hasUB(i)&&numel(ub)>0
                dx(i)=min(ub(i),dx(i));
            end
            dxInfNorm=max(dxInfNorm,abs(dx(i)));
        end
    else
        for i=1:n
            if hasLB(i)&&numel(lb)>0
                dx(i)=max(lb(i)-x(i),dx(i));
            end
            if hasUB(i)&&numel(ub)>0
                dx(i)=min(ub(i)-x(i),dx(i));
            end
            dxInfNorm=max(dxInfNorm,abs(dx(i)));
        end
    end

end
