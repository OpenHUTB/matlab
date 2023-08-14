function[interpolant,fx]=akima1d_private(x,f)%#codegen




    coder.allowpcode('plain');



    tol=1e-12;


    x=x(:);
    n=length(x);
    f=f(:);
    assert(length(f)==n,message('physmod:simscape:compiler:patterns:checks:LengthEqualLength','f','x'))
    Dx=diff(x);
    assert(all(Dx>0),message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec','x'))


    x_scale=(x(n)-x(1))/2;
    f_scale_ref=(max(f(:))-min(f(:)))/2;
    if f_scale_ref~=0
        f_scale=f_scale_ref;
    else
        f_scale=1;
    end
    tol=tol*f_scale/x_scale;


    fx=computeDerivative1(f,Dx,tol);


    interpolant=@(t,extrapMethod)...
    evalInterpolant(x,f,fx,t,extrapMethod);

end




function[fi,gi]=evalInterpolant(x,f,fx,t,extrapMethod)

    if strcmpi(extrapMethod,'linear')
        extrapMethod=1;
    elseif strcmpi(extrapMethod,'nearest')
        extrapMethod=0;
    else
        error(message('physmod:ee:library:Either','extrapMethod','nearest','linear'))
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