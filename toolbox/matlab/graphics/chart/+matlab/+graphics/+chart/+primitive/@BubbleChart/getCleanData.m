function[order,x,y,z,s,a,c]=getCleanData(~,x,y,z,s,a,c,stripnanc)




    order=1:numel(x);

    nani=isfinite(x)&isfinite(y)&isfinite(z)&~isnan(s);

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

    if~isscalar(s)
        [~,sortind]=sort(s,'descend');
        x=x(sortind);
        y=y(sortind);
        z=z(sortind);
        s=s(sortind);
        if size(c,1)==numel(sortind)
            c=c(sortind,:);
        end
        order=order(sortind);
    end
end
