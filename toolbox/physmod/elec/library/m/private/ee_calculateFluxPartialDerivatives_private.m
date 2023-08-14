function[dFdA,dFdB,dFdC,dFdX,D,Q]=ee_calculateFluxPartialDerivatives_private(A,B,C,X,F)







    n_x=numel(X);
    n_a=numel(A);
    n_b=numel(B);
    n_c=numel(C);


    if nargout>4
        D=A;
        Q=A;
        n_d=n_a;
        n_q=n_a;
    end



    if abs(X(1))~=0
        pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_RotorAngleVector')))
    end
    if X(n_x)>2*pi
        pm_error('physmod:simscape:compiler:patterns:checks:LessThanOrEqual',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_LastElementOfRotorAngleVector')),'2*pi')
    end


    if n_x<=2
        pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_RotorAngleVector')),'2');
    end


    if any(diff(X)<=0)
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_RotorAngleVector')))
    end


    if any(diff(A)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_AphaseCurrentVector'))),end
    if any(diff(B)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_BphaseCurrentVector'))),end
    if any(diff(C)<=0),pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_CphaseCurrentVector'))),end


    if n_a<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_AphaseCurrentVector')),'2'),end
    if n_b<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_BphaseCurrentVector')),'2'),end
    if n_c<=2,pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThan',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_CphaseCurrentVector')),'2'),end


    if(A(1)>=0)||(A(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_AphaseCurrentVector')))
    end
    if(B(1)>=0)||(B(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_BphaseCurrentVector')))
    end
    if(C(1)>=0)||(C(end)<=0)
        pm_error('physmod:ee:library:PositiveAndNegativeValues',getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_CphaseCurrentVector')))
    end


    if~all(size(F)==[n_a,n_b,n_c,n_x])
        pm_error('physmod:simscape:compiler:patterns:checks:Size4DEqual',...
        getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_FluxLinkageMatrixFABCX')),getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_AphaseCurrentVector')),...
        getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_BphaseCurrentVector')),getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_CphaseCurrentVector')),...
        getString(message('physmod:ee:library:comments:private:ee_calculateFluxPartialDerivatives_private:error_RotorAngleVector')));
    end


    X=X(:);
    A=A(:);
    B=B(:);
    C=C(:);


    X2=[X(end-2:end-1)-X(end);X;X(2:3)+X(end)];
    F2=cat(4,F(:,:,:,end-2:end-1),F,F(:,:,:,2:3));


    [~,dFdA2,dFdB2,dFdC2,dFdX2]=akima4d(A,B,C,X2,F2);


    dFdA1=dFdA2(:,:,:,3:end-2);
    dFdB1=dFdB2(:,:,:,3:end-2);
    dFdC1=dFdC2(:,:,:,3:end-2);
    dFdX1=dFdX2(:,:,:,3:end-2);

    if nargout<=4
        dFdA=dFdA1;
        dFdB=dFdB1;
        dFdC=dFdC1;
        dFdX=dFdX1;
    else

        dFdA2=cat(4,dFdA1(:,:,:,end-2:end-1),dFdA1,dFdA1(:,:,:,2:3));
        dFdB2=cat(4,dFdB1(:,:,:,end-2:end-1),dFdB1,dFdB1(:,:,:,2:3));
        dFdC2=cat(4,dFdC1(:,:,:,end-2:end-1),dFdC1,dFdC1(:,:,:,2:3));
        dFdX2=cat(4,dFdX1(:,:,:,end-2:end-1),dFdX1,dFdX1(:,:,:,2:3));
        akima_dFdA2=akima4d(A,B,C,X2,dFdA2);
        akima_dFdB2=akima4d(A,B,C,X2,dFdB2);
        akima_dFdC2=akima4d(A,B,C,X2,dFdC2);
        akima_dFdX2=akima4d(A,B,C,X2,dFdX2);


        dFdA=zeros(n_d,n_q,n_x);
        dFdB=zeros(n_d,n_q,n_x);
        dFdC=zeros(n_d,n_q,n_x);
        dFdX=zeros(n_d,n_q,n_x);
        N=2*pi/X(end);
        for i=1:n_d
            for j=1:n_q
                for k=1:n_x
                    shift_3ph=[0,-2*pi/3,2*pi/3];
                    electrical_angle=N*X(k);



                    dq2abc=[cos(electrical_angle+shift_3ph)',-sin(electrical_angle+shift_3ph)'];
                    iABC=dq2abc*[D(i);Q(j)];
                    dFdA(i,j,k)=akima_dFdA2(iABC(1),iABC(2),iABC(3),X(k),'linear');
                    dFdB(i,j,k)=akima_dFdB2(iABC(1),iABC(2),iABC(3),X(k),'linear');
                    dFdC(i,j,k)=akima_dFdC2(iABC(1),iABC(2),iABC(3),X(k),'linear');
                    dFdX(i,j,k)=akima_dFdX2(iABC(1),iABC(2),iABC(3),X(k),'linear');
                end
            end
        end
    end


end