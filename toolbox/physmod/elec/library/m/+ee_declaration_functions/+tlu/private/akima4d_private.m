function[interpolant,fx1,fx2,fx3,fx4,fx12,fx13,fx14,fx23,fx24,fx34,fx123,fx124,fx134,fx234,fx1234]=akima4d_private(x1,x2,x3,x4,f)%#codegen




    coder.allowpcode('plain');



    tol=1e-12;


    x1=x1(:);
    x2=x2(:);
    x3=x3(:);
    x4=x4(:);
    n1=length(x1);
    n2=length(x2);
    n3=length(x3);
    n4=length(x4);
    Dx1=diff(x1);
    Dx2=diff(x2);
    Dx3=diff(x3);
    Dx4=diff(x4);


    x1_scale=(x1(n1)-x1(1))/2;
    x2_scale=(x2(n2)-x2(1))/2;
    x3_scale=(x3(n3)-x3(1))/2;
    x4_scale=(x4(n4)-x4(1))/2;
    f_scale_ref=(max(f(:))-min(f(:)))/2;
    if f_scale_ref~=0
        f_scale=f_scale_ref;
    else
        f_scale=1;
    end
    tol1=tol*f_scale/x1_scale;
    tol2=tol*f_scale/x2_scale;
    tol3=tol*f_scale/x3_scale;
    tol4=tol*f_scale/x4_scale;


    [fx1,wgt1,finiteDiff1]=computeDerivative1(f,Dx1,tol1);


    [fx2,wgt2,finiteDiff2]=computeDerivative1(permute(f,[2,3,4,1]),Dx2,tol2);
    fx2=permute(fx2,[4,1,2,3]);
    wgt2=permute(wgt2,[4,1,2,3]);
    finiteDiff2=permute(finiteDiff2,[4,1,2,3]);


    [fx3,wgt3,finiteDiff3]=computeDerivative1(permute(f,[3,4,1,2]),Dx3,tol3);
    fx3=permute(fx3,[3,4,1,2]);
    wgt3=permute(wgt3,[3,4,1,2]);
    finiteDiff3=permute(finiteDiff3,[3,4,1,2]);


    [fx4,wgt4,finiteDiff4]=computeDerivative1(permute(f,[4,1,2,3]),Dx4,tol4);
    fx4=permute(fx4,[2,3,4,1]);
    wgt4=permute(wgt4,[2,3,4,1]);
    finiteDiff4=permute(finiteDiff4,[2,3,4,1]);


    [fx12,finiteDiff12]=computeDerivative12(finiteDiff2,Dx1,wgt1,wgt2,tol1,tol2);


    [fx13,finiteDiff13]=computeDerivative12(permute(finiteDiff3,[1,3,2,4]),Dx1,...
    permute(wgt1,[1,3,2,4]),permute(wgt3,[1,3,2,4]),tol1,tol3);
    fx13=permute(fx13,[1,3,2,4]);
    finiteDiff13=permute(finiteDiff13,[1,3,2,4]);%#ok<NASGU>


    [fx14,finiteDiff14]=computeDerivative12(permute(finiteDiff1,[4,1,2,3]),Dx4,...
    permute(wgt4,[4,1,2,3]),permute(wgt1,[4,1,2,3]),tol4,tol1);
    fx14=permute(fx14,[2,3,4,1]);
    finiteDiff14=permute(finiteDiff14,[2,3,4,1]);


    [fx23,finiteDiff23]=computeDerivative12(permute(finiteDiff3,[2,3,4,1]),Dx2,...
    permute(wgt2,[2,3,4,1]),permute(wgt3,[2,3,4,1]),tol2,tol3);
    fx23=permute(fx23,[4,1,2,3]);
    finiteDiff23=permute(finiteDiff23,[4,1,2,3]);


    [fx24,finiteDiff24]=computeDerivative12(permute(finiteDiff4,[2,4,1,3]),Dx2,...
    permute(wgt2,[2,4,1,3]),permute(wgt4,[2,4,1,3]),tol2,tol4);
    fx24=permute(fx24,[3,1,4,2]);
    finiteDiff24=permute(finiteDiff24,[3,1,4,2]);%#ok<NASGU>


    [fx34,finiteDiff34]=computeDerivative12(permute(finiteDiff4,[3,4,1,2]),Dx3,...
    permute(wgt3,[3,4,1,2]),permute(wgt4,[3,4,1,2]),tol3,tol4);
    fx34=permute(fx34,[3,4,1,2]);
    finiteDiff34=permute(finiteDiff34,[3,4,1,2]);


    [fx123,~]=computeDerivative123(finiteDiff23,Dx1,wgt1,wgt2,wgt3,tol1,tol2,tol3);


    [fx124,finiteDiff124]=computeDerivative123(permute(finiteDiff12,[4,1,2,3]),Dx4,...
    permute(wgt4,[4,1,2,3]),permute(wgt1,[4,1,2,3]),permute(wgt2,[4,1,2,3]),tol4,tol1,tol2);
    fx124=permute(fx124,[2,3,4,1]);
    finiteDiff124=permute(finiteDiff124,[2,3,4,1]);%#ok<NASGU>


    [fx134,finiteDiff134]=computeDerivative123(permute(finiteDiff14,[3,4,1,2]),Dx3,...
    permute(wgt3,[3,4,1,2]),permute(wgt4,[3,4,1,2]),permute(wgt1,[3,4,1,2]),tol3,tol4,tol1);
    fx134=permute(fx134,[3,4,1,2]);
    finiteDiff134=permute(finiteDiff134,[3,4,1,2]);%#ok<NASGU>


    [fx234,finiteDiff234]=computeDerivative123(permute(finiteDiff34,[2,3,4,1]),Dx2,...
    permute(wgt2,[2,3,4,1]),permute(wgt3,[2,3,4,1]),permute(wgt4,[2,3,4,1]),tol2,tol3,tol4);
    fx234=permute(fx234,[4,1,2,3]);
    finiteDiff234=permute(finiteDiff234,[4,1,2,3]);


    [fx1234,~]=computeDerivative1234(finiteDiff234,Dx1,wgt1,wgt2,wgt3,wgt4,...
    tol1,tol2,tol3,tol4);


    interpolant=@(t1,t2,t3,t4,extrapMethod)...
    evalInterpolant(x1,x2,x3,x4,f,fx1,fx2,fx3,fx4,fx12,fx13,fx14,fx23,fx24,fx34,...
    fx123,fx124,fx134,fx234,fx1234,t1,t2,t3,t4,extrapMethod);

end




function[fi,gi]=evalInterpolant(x1,x2,x3,x4,f,fx1,fx2,fx3,fx4,...
    fx12,fx13,fx14,fx23,fx24,fx34,fx123,fx124,fx134,fx234,fx1234,t1,t2,t3,t4,extrapMethod)

    if strcmpi(extrapMethod,'linear')
        extrapMethod=1;
    elseif strcmpi(extrapMethod,'nearest')
        extrapMethod=0;
    end

    x1=x1(:);
    x2=x2(:);
    x3=x3(:);
    x4=x4(:);
    n1=length(x1);
    n2=length(x2);
    n3=length(x3);
    n4=length(x4);


    dims=size(t1);
    t1=t1(:);
    t2=t2(:);
    t3=t3(:);
    t4=t4(:);
    m=length(t1);


    if nargout==1
        [bin1,H1,Hx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
        [bin3,H3,Hx3]=evalHermiteBases(x3,n3,t3,m,extrapMethod);
        [bin4,H4,Hx4]=evalHermiteBases(x4,n4,t4,m,extrapMethod);
    else
        [bin1,H1,Hx1,G1,Gx1]=evalHermiteBases(x1,n1,t1,m,extrapMethod);
        [bin2,H2,Hx2,G2,Gx2]=evalHermiteBases(x2,n2,t2,m,extrapMethod);
        [bin3,H3,Hx3,G3,Gx3]=evalHermiteBases(x3,n3,t3,m,extrapMethod);
        [bin4,H4,Hx4,G4,Gx4]=evalHermiteBases(x4,n4,t4,m,extrapMethod);
    end


    bin=sub2ind([n1,n2,n3,n4],bin1,bin2,bin3,bin4);


    fi=zeros(m,1);
    if nargout>1
        gi=zeros(m,4);
    end
    for i4=1:2
        I4=n1*n2*n3*(i4-1)+bin;

        for i3=1:2
            I3=n1*n2*(i3-1)+I4;

            for i2=1:2
                I2=n1*(i2-1)+I3;

                for i1=1:2
                    I1=(i1-1)+I2;

                    fi=fi+(((f(I1).*H1(:,i1)...
                    +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx2(I1).*H1(:,i1)...
                    +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                    +((fx3(I1).*H1(:,i1)...
                    +fx13(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx23(I1).*H1(:,i1)...
                    +fx123(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*H4(:,i4)...
                    +(((fx4(I1).*H1(:,i1)...
                    +fx14(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx24(I1).*H1(:,i1)...
                    +fx124(I1).*Hx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                    +((fx34(I1).*H1(:,i1)...
                    +fx134(I1).*Hx1(:,i1)).*H2(:,i2)...
                    +(fx234(I1).*H1(:,i1)...
                    +fx1234(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*Hx4(:,i4);

                    if nargout>1
                        gi(:,1)=gi(:,1)+(((f(I1).*G1(:,i1)...
                        +fx1(I1).*Gx1(:,i1)).*H2(:,i2)...
                        +(fx2(I1).*G1(:,i1)...
                        +fx12(I1).*Gx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                        +((fx3(I1).*G1(:,i1)...
                        +fx13(I1).*Gx1(:,i1)).*H2(:,i2)...
                        +(fx23(I1).*G1(:,i1)...
                        +fx123(I1).*Gx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*H4(:,i4)...
                        +(((fx4(I1).*G1(:,i1)...
                        +fx14(I1).*Gx1(:,i1)).*H2(:,i2)...
                        +(fx24(I1).*G1(:,i1)...
                        +fx124(I1).*Gx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                        +((fx34(I1).*G1(:,i1)...
                        +fx134(I1).*Gx1(:,i1)).*H2(:,i2)...
                        +(fx234(I1).*G1(:,i1)...
                        +fx1234(I1).*Gx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*Hx4(:,i4);

                        gi(:,2)=gi(:,2)+(((f(I1).*H1(:,i1)...
                        +fx1(I1).*Hx1(:,i1)).*G2(:,i2)...
                        +(fx2(I1).*H1(:,i1)...
                        +fx12(I1).*Hx1(:,i1)).*Gx2(:,i2)).*H3(:,i3)...
                        +((fx3(I1).*H1(:,i1)...
                        +fx13(I1).*Hx1(:,i1)).*G2(:,i2)...
                        +(fx23(I1).*H1(:,i1)...
                        +fx123(I1).*Hx1(:,i1)).*Gx2(:,i2)).*Hx3(:,i3)).*H4(:,i4)...
                        +(((fx4(I1).*H1(:,i1)...
                        +fx14(I1).*Hx1(:,i1)).*G2(:,i2)...
                        +(fx24(I1).*H1(:,i1)...
                        +fx124(I1).*Hx1(:,i1)).*Gx2(:,i2)).*H3(:,i3)...
                        +((fx34(I1).*H1(:,i1)...
                        +fx134(I1).*Hx1(:,i1)).*G2(:,i2)...
                        +(fx234(I1).*H1(:,i1)...
                        +fx1234(I1).*Hx1(:,i1)).*Gx2(:,i2)).*Hx3(:,i3)).*Hx4(:,i4);

                        gi(:,3)=gi(:,3)+(((f(I1).*H1(:,i1)...
                        +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx2(I1).*H1(:,i1)...
                        +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2)).*G3(:,i3)...
                        +((fx3(I1).*H1(:,i1)...
                        +fx13(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx23(I1).*H1(:,i1)...
                        +fx123(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Gx3(:,i3)).*H4(:,i4)...
                        +(((fx4(I1).*H1(:,i1)...
                        +fx14(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx24(I1).*H1(:,i1)...
                        +fx124(I1).*Hx1(:,i1)).*Hx2(:,i2)).*G3(:,i3)...
                        +((fx34(I1).*H1(:,i1)...
                        +fx134(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx234(I1).*H1(:,i1)...
                        +fx1234(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Gx3(:,i3)).*Hx4(:,i4);

                        gi(:,4)=gi(:,4)+(((f(I1).*H1(:,i1)...
                        +fx1(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx2(I1).*H1(:,i1)...
                        +fx12(I1).*Hx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                        +((fx3(I1).*H1(:,i1)...
                        +fx13(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx23(I1).*H1(:,i1)...
                        +fx123(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*G4(:,i4)...
                        +(((fx4(I1).*H1(:,i1)...
                        +fx14(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx24(I1).*H1(:,i1)...
                        +fx124(I1).*Hx1(:,i1)).*Hx2(:,i2)).*H3(:,i3)...
                        +((fx34(I1).*H1(:,i1)...
                        +fx134(I1).*Hx1(:,i1)).*H2(:,i2)...
                        +(fx234(I1).*H1(:,i1)...
                        +fx1234(I1).*Hx1(:,i1)).*Hx2(:,i2)).*Hx3(:,i3)).*Gx4(:,i4);
                    end
                end
            end
        end
    end


    fi=reshape(fi,dims);
    if nargout>1
        gi=reshape(gi,[dims,4]);
    end

end