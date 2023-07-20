function[order,x,y,z,s,a,c]=getCleanData(~,x,y,z,s,a,c,stripnanc)




    order=1:numel(x);
    nani=isfinite(x(:))&isfinite(y(:))&isfinite(z(:))&isfinite(s(:));
    x=x(nani);
    y=y(nani);
    z=z(nani);

    if~isscalar(a)||isscalar(nani)
        a=a(nani);
    end
    if~isscalar(s)||isscalar(nani)
        s=s(nani);
    end
    order=order(nani);
    if stripnanc
        c=c(nani,:);
    end

end
