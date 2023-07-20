function[F,T,dFdA,dFdB,dFdC,dFdX]=ee_generateIdealPMSMfluxData3D_private(PM,Ld,Lq,L0,D,Q,X)








    D=D(:);
    Q=Q(:);
    X=X(:);
    n_d=numel(D);
    n_q=numel(Q);
    n_x=numel(X);


    if abs(X(1))~=0
        pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_RotorAngleVector')))
    end
    if X(n_x)>2*pi
        pm_error('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_LastElementOfRotorAngleVector')),'2*pi')
    end
    N=2*pi/X(n_x);


    if n_x<=2
        pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_RotorAngleVector')),'2');
    end


    if any(diff(X)<=0)
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_RotorAngleVector')))
    end


    if any(diff(D)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_DaxisCurrentVector'))),end
    if any(diff(Q)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_QaxisCurrentVector'))),end


    if n_d<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_DaxisCurrentVector')),'2'),end
    if n_q<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_QaxisCurrentVector')),'2'),end


    if(D(1)>=0)||(D(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_DaxisCurrentVector')))
    end
    if(Q(1)>=0)||(Q(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_generateIdealPMSMfluxData3D_private:error_QaxisCurrentVector')))
    end


    Ls=L0/3+Ld/3+Lq/3;
    Ms=Ld/6-L0/3+Lq/6;
    Lm=Ld/3-Lq/3;

    E=N*X;
    Laa=Ls+Lm*cos(2*E);
    Lab=-Ms+Lm*cos(2*E-2*pi/3);
    Lac=-Ms+Lm*cos(2*E+2*pi/3);
    PHIa=PM*cos(E);


    F=zeros(n_d,n_q,n_x);
    dFdA=zeros(n_d,n_q,n_x);
    dFdB=zeros(n_d,n_q,n_x);
    dFdC=zeros(n_d,n_q,n_x);
    dFdX=zeros(n_d,n_q,n_x);
    shift_3ph=[0,-2*pi/3,2*pi/3];
    for i=1:n_d
        for j=1:n_q
            dFdA(i,j,:)=Laa;
            dFdB(i,j,:)=Lab;
            dFdC(i,j,:)=Lac;
            dPHIa_dx=-PM*N*sin(E);
            dLaa_dx=-2*N*Lm*sin(2*E);
            dLab_dx=-2*N*Lm*sin(2*E-2*pi/3);
            dLac_dx=-2*N*Lm*sin(2*E+2*pi/3);
            for m=1:n_x

                electrical_angle=E(m);
                dq2abc=[cos(electrical_angle+shift_3ph)'...
                ,-sin(electrical_angle+shift_3ph)'];
                Iabc=dq2abc*[D(i);Q(j)];
                dFdX(i,j,m)=[dLaa_dx(m),dLab_dx(m),dLac_dx(m)]...
                *Iabc+dPHIa_dx(m);
                F(i,j,m)=PHIa(m)+[Laa(m),Lab(m),Lac(m)]*Iabc;
            end
        end
    end


    T=zeros(n_d,n_q,n_x);
    for i=1:n_d
        for j=1:n_q
            for m=1:n_x
                i_d=D(i);
                i_q=Q(j);
                Ld=Ls+Ms+(3/2)*Lm;
                Lq=Ls+Ms-(3/2)*Lm;
                psi_d=i_d*Ld+PM;
                psi_q=i_q*Lq;
                T(i,j,m)=3/2*N*(i_q*psi_d-i_d*psi_q);
            end
        end
    end

end