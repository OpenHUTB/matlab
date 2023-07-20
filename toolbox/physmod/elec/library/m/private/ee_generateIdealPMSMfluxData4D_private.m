function[F,T,dFdA,dFdB,dFdC,dFdX]=ee_generateIdealPMSMfluxData4D_private(PM,Ld,Lq,L0,A,B,C,X)








    A=A(:);
    B=B(:);
    C=C(:);
    X=X(:);
    n_a=numel(A);
    n_b=numel(B);
    n_c=numel(C);
    n_x=numel(X);


    if abs(X(1))~=0
        pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_RotorAngleVector')))
    end
    if X(n_x)>2*pi
        pm_error('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_LastElementOfRotorAngleVector')),'2*pi')
    end
    N=2*pi/X(n_x);


    if n_x<=2
        pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_RotorAngleVector')),'2');
    end


    if any(diff(X)<=0)
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_RotorAngleVector')))
    end


    if any(diff(A)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_AphaseCurrentVector'))),end
    if any(diff(B)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_BphaseCurrentVector'))),end
    if any(diff(C)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_CphaseCurrentVector'))),end


    if n_a<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_AphaseCurrentVector')),'2'),end
    if n_b<=2,pm_error('pphysmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_BphaseCurrentVector')),'2'),end
    if n_c<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_CphaseCurrentVector')),'2'),end


    if(A(1)>=0)||(A(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_AphaseCurrentVector')))
    end
    if(B(1)>=0)||(B(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_BphaseCurrentVector')))
    end
    if(C(1)>=0)||(C(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData4D_private:error_CphaseCurrentVector')))
    end





    Ls=L0/3+Ld/3+Lq/3;
    Ms=Ld/6-L0/3+Lq/6;
    Lm=Ld/3-Lq/3;

    E=N*X;
    Laa=Ls+Lm*cos(2*E);
    Lab=-Ms+Lm*cos(2*E-2*pi/3);
    Lac=-Ms+Lm*cos(2*E+2*pi/3);
    PHIa=PM*cos(E);


    F=zeros(n_a,n_b,n_c,n_x);
    dFdA=zeros(n_a,n_b,n_c,n_x);
    dFdB=zeros(n_a,n_b,n_c,n_x);
    dFdC=zeros(n_a,n_b,n_c,n_x);
    dFdX=zeros(n_a,n_b,n_c,n_x);
    for i=1:n_a
        ia=A(i);
        for j=1:n_b
            ib=B(j);
            for k=1:n_c
                ic=C(k);
                F(i,j,k,:)=PHIa+ia.*Laa+ib.*Lab+ic.*Lac;
                dFdA(i,j,k,:)=Laa;
                dFdB(i,j,k,:)=Lab;
                dFdC(i,j,k,:)=Lac;
                dPHIa_dx=-PM*N*sin(E);
                dLaa_dx=-2*N*Lm*sin(2*E);
                dLab_dx=-2*N*Lm*sin(2*E-2*pi/3);
                dLac_dx=-2*N*Lm*sin(2*E+2*pi/3);
                for m=1:n_x
                    dFdX(i,j,k,m)=[dLaa_dx(m),dLab_dx(m),dLac_dx(m)]...
                    *[A(i);B(j);C(k)]+dPHIa_dx(m);
                end
            end
        end
    end


    T=zeros(n_a,n_b,n_c,n_x);
    shift_3ph=[0,-2*pi/3,2*pi/3];
    for i=1:n_a
        for j=1:n_b
            for k=1:n_c
                for m=1:n_x
                    electrical_angle=E(m);

                    abc2dq=2/3*[...
                    cos(electrical_angle+shift_3ph);...
                    -sin(electrical_angle+shift_3ph)];
                    Idq=abc2dq*[A(i);B(j);C(k)];
                    i_d=Idq(1);
                    i_q=Idq(2);
                    Ld=Ls+Ms+(3/2)*Lm;
                    Lq=Ls+Ms-(3/2)*Lm;
                    psi_d=i_d*Ld+PM;
                    psi_q=i_q*Lq;
                    T(i,j,k,m)=3/2*N*(i_q*psi_d-i_d*psi_q);
                end
            end
        end
    end

end