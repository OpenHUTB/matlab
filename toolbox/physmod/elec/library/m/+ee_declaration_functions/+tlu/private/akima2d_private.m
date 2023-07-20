function[interpolant,fx1,fx2,fx12]=akima2d_private(x1,x2,f)%#codegen




    coder.allowpcode('plain');


    tol=1e-12;


    x1=x1(:);
    x2=x2(:);
    n1=length(x1);
    n2=length(x2);
    assert(all(size(f)==[n1,n2]),message('physmod:simscape:compiler:patterns:checks:Size2DEqual','f','x1','x2'))
    Dx1=diff(x1);
    Dx2=diff(x2);
    assert(all(Dx1>0),message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec','x1'))
    assert(all(Dx2>0),message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec','x2'))


    x1_scale=(x1(n1)-x1(1))/2;
    x2_scale=(x2(n2)-x2(1))/2;
    f_scale_ref=(max(f(:))-min(f(:)))/2;
    if f_scale_ref~=0
        f_scale=f_scale_ref;
    else
        f_scale=1;
    end
    tol1=tol*f_scale/x1_scale;
    tol2=tol*f_scale/x2_scale;


    [fx1,wgt1]=computeDerivative1(f,Dx1,tol1);


    [fx2,wgt2,finiteDiff2]=computeDerivative1(f',Dx2,tol2);
    fx2=fx2';
    wgt2=wgt2';
    finiteDiff2=finiteDiff2';


    fx12=computeDerivative12(finiteDiff2,Dx1,wgt1,wgt2,tol1,tol2);


    interpolant=@(t1,t2,extrapMethod)...
    evalInterpolant(x1,x2,f,fx1,fx2,fx12,t1,t2,extrapMethod);

end




function[fi,gi]=evalInterpolant(x1,x2,f,fx1,fx2,fx12,t1,t2,extrapMethod)

    if strcmpi(extrapMethod,'linear')
        extrapMethod=1;
    elseif strcmpi(extrapMethod,'nearest')
        extrapMethod=0;
    else
        error(message('physmod:ee:library:Either','extrapMethod','nearest','linear'))
    end

    x1=x1(:);
    x2=x2(:);
    n1=length(x1);
    n2=length(x2);


    dims=size(t1);
    if any(dims~=size(t2))
        error(message('physmod:ee:library:DimensionsEqual','t1','t2'))
    end
    t1=t1(:);
    t2=t2(:);
    m=length(t1);


    if nargout==1
        [bin1,H1,Hx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
    else
        [bin1,H1,Hx1,G1,Gx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2,G2,Gx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
    end


    bin=sub2ind([n1,n2],bin1,bin2);


    fi=zeros(m,1);
    if nargout>1
        gi=zeros(m,2);
    end
    for i2=1:2
        I2=n1*(i2-1)+bin;

        for i1=1:2
            I1=(i1-1)+I2;

            fi=fi+(f(I1).*H1(:,i1)...
            +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
            +(fx2(I1).*H1(:,i1)...
            +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2);

            if nargout>1
                gi(:,1)=gi(:,1)+(f(I1).*G1(:,i1)...
                +fx1(I1).*Gx1(:,i1)).*H2(:,i2)...
                +(fx2(I1).*G1(:,i1)...
                +fx12(I1).*Gx1(:,i1)).*Hx2(:,i2);

                gi(:,2)=gi(:,2)+(f(I1).*H1(:,i1)...
                +fx1(I1).*Hx1(:,i1)).*G2(:,i2)...
                +(fx2(I1).*H1(:,i1)...
                +fx12(I1).*Hx1(:,i1)).*Gx2(:,i2);
            end
        end
    end


    fi=reshape(fi,dims);
    if nargout>1
        gi=reshape(gi,[dims,2]);
    end

end