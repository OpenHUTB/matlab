function[interpolant,fx]=akima1d(x,f)


    x=x(:);
    n=length(x);
    f=f(:);
    assert(length(f)==n,'The length of f must match of the length of x.')
    Dx=diff(x);
    assert(all(Dx>0),'x must be strictly monotonically increasing.')


    fx=computeDerivative1(f,Dx);


    interpolant=@(t,extrapMethod)...
    evalInterpolant(x,f,fx,t,extrapMethod);

end




function[fi,gi]=evalInterpolant(x,f,fx,t,extrapMethod)

    if strcmpi(extrapMethod,'linear')
        extrapMethod=1;
    elseif strcmpi(extrapMethod,'nearest')
        extrapMethod=0;
    else
        error('extrapMethod must be either ''nearest'' or ''linear''.')
    end

    x=x(:);
    n=length(x);


    dims=size(t);
    t=t(:);
    m=length(t);


    if nargout==1
        [bin,H,Hx]=evalHermiteBases(x,n,t,m,extrapMethod);
    else
        [bin,H,Hx,G,Gx]=evalHermiteBases(x,n,t,m,extrapMethod);
    end


    fi=f(bin).*H(:,1)+fx(bin).*Hx(:,1)+f(bin+1).*H(:,2)+fx(bin+1).*Hx(:,2);
    if nargout>1
        gi=f(bin).*G(:,1)+fx(bin).*Gx(:,1)+f(bin+1).*G(:,2)+fx(bin+1).*Gx(:,2);
    end


    fi=reshape(fi,dims);
    if nargout>1
        gi=reshape(gi,dims);
    end

end