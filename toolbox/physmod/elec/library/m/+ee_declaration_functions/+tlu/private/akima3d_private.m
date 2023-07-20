function[interpolant,fx1,fx2,fx3,fx12,fx23,fx31,fx123]=akima3d_private(x1,x2,x3,f)%#codegen




    coder.allowpcode('plain');


    tol=1e-12;


    x1=x1(:);
    x2=x2(:);
    x3=x3(:);
    n1=length(x1);
    n2=length(x2);
    n3=length(x3);
    Dx1=diff(x1);
    Dx2=diff(x2);
    Dx3=diff(x3);


    x1_scale=(x1(n1)-x1(1))/2;
    x2_scale=(x2(n2)-x2(1))/2;
    x3_scale=(x3(n3)-x3(1))/2;
    f_scale_ref=(max(f(:))-min(f(:)))/2;
    if f_scale_ref~=0
        f_scale=f_scale_ref;
    else
        f_scale=1;
    end
    tol1=tol*f_scale/x1_scale;
    tol2=tol*f_scale/x2_scale;
    tol3=tol*f_scale/x3_scale;


    [fx1,wgt1,finiteDiff1]=computeDerivative1(f,Dx1,tol1);


    [fx2,wgt2,finiteDiff2]=computeDerivative1(permute(f,[2,3,1]),Dx2,tol2);
    fx2=permute(fx2,[3,1,2]);
    wgt2=permute(wgt2,[3,1,2]);
    finiteDiff2=permute(finiteDiff2,[3,1,2]);


    [fx3,wgt3,finiteDiff3]=computeDerivative1(permute(f,[3,1,2]),Dx3,tol3);
    fx3=permute(fx3,[2,3,1]);
    wgt3=permute(wgt3,[2,3,1]);
    finiteDiff3=permute(finiteDiff3,[2,3,1]);


    fx12=computeDerivative12(finiteDiff2,Dx1,wgt1,wgt2,tol1,tol2);


    [fx23,finiteDiff23]=computeDerivative12(permute(finiteDiff3,[2,3,1]),Dx2,...
    permute(wgt2,[2,3,1]),permute(wgt3,[2,3,1]),tol2,tol3);
    fx23=permute(fx23,[3,1,2]);
    finiteDiff23=permute(finiteDiff23,[3,1,2]);


    fx31=computeDerivative12(permute(finiteDiff1,[3,1,2]),Dx3,...
    permute(wgt3,[3,1,2]),permute(wgt1,[3,1,2]),tol3,tol1);
    fx31=permute(fx31,[2,3,1]);


    fx123=computeDerivative123(finiteDiff23,Dx1,wgt1,wgt2,wgt3,tol1,tol2,tol3);


    interpolant=@(t1,t2,t3,extrapMethod)...
    evalInterpolant(x1,x2,x3,f,fx1,fx2,fx3,fx12,fx23,fx31,fx123,t1,t2,t3,extrapMethod);

end




function[fi,gi]=evalInterpolant(x1,x2,x3,f,fx1,fx2,fx3,fx12,fx23,fx31,fx123,...
    t1,t2,t3,extrapMethod)

    if strcmpi(extrapMethod,'linear')
        extrapMethod=1;
    elseif strcmpi(extrapMethod,'nearest')
        extrapMethod=0;
    end

    x1=x1(:);
    x2=x2(:);
    x3=x3(:);
    n1=length(x1);
    n2=length(x2);
    n3=length(x3);


    dims=size(t1);
    t1=t1(:);
    t2=t2(:);
    t3=t3(:);
    m=length(t1);


    if nargout==1
        [bin1,H1,Hx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
        [bin3,H3,Hx3]=evalHermiteBases(x3,n3,t3,m,extrapMethod);
    else
        [bin1,H1,Hx1,G1,Gx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2,G2,Gx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
        [bin3,H3,Hx3,G3,Gx3]=evalHermiteBases(x3,n3,t3,m,extrapMethod);
    end


    bin=sub2ind([n1,n2,n3],bin1,bin2,bin3);


    fi=zeros(m,1);
    if nargout>1
        gi=zeros(m,3);
    end
    for i3=1:2
        I3=n1*n2*(i3-1)+bin;

        for i2=1:2
            I2=n1*(i2-1)+I3;

            for i1=1:2
                I1=(i1-1)+I2;

                fi=fi+((f(I1).*H1(:,i1)...
                +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
                +(fx2(I1).*H1(:,i1)...
                +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                +((fx3(I1).*H1(:,i1)...
                +fx31(I1).*Hx1(:,i1)).*H2(:,i2)...
                +(fx23(I1).*H1(:,i1)...
                +fx123(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3);

                if nargout>1
                    gi(:,1)=gi(:,1)+((f(I1).*G1(:,i1)...
                    +fx1(I1).*Gx1(:,i1)).*H2(:,i2)...
                    +(fx2(I1).*G1(:,i1)...
                    +fx12(I1).*Gx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                    +((fx3(I1).*G1(:,i1)...
                    +fx31(I1).*Gx1(:,i1)).*H2(:,i2)...
                    +(fx23(I1).*G1(:,i1)...
                    +fx123(I1).*Gx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3);

                    gi(:,2)=gi(:,2)+((f(I1).*H1(:,i1)...
                    +fx1(I1).*Hx1(:,i1)).*G2(:,i2)...
                    +(fx2(I1).*H1(:,i1)...
                    +fx12(I1).*Hx1(:,i1)).*Gx2(:,i2)).*H3(:,i3)...
                    +((fx3(I1).*H1(:,i1)...
                    +fx31(I1).*Hx1(:,i1)).*G2(:,i2)...
                    +(fx23(I1).*H1(:,i1)...
                    +fx123(I1).*Hx1(:,i1)).*Gx2(:,i2)).*Hx3(:,i3);

                    gi(:,3)=gi(:,3)+((f(I1).*H1(:,i1)...
                    +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx2(I1).*H1(:,i1)...
                    +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2)).*G3(:,i3)...
                    +((fx3(I1).*H1(:,i1)...
                    +fx31(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx23(I1).*H1(:,i1)...
                    +fx123(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Gx3(:,i3);
                end
            end
        end
    end


    fi=reshape(fi,dims);
    if nargout>1
        gi=reshape(gi,[dims,3]);
    end

end