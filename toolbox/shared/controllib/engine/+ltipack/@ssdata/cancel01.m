function[a,b,c]=cancel01(a0,b0,c0,d,Ts,fTest,RelTol)









    a=a0;b=b0;c=c0;
    n=size(a0,1);
    if Ts==0
        sTest=1i*fTest;
    else
        sTest=exp(1i*fTest*Ts);
    end
    h0=c0*((sTest*eye(n)-a0)\b0);
    nrmh0=norm(d+h0,1);


    for ct=1:n
        if Ts==0
            as0=a0;
        else
            as0=a0-eye(n);
        end
        nrmA=norm(as0,1);
        nrmBC=norm(b0,1);
        [w,s_ab,~]=svd([as0/nrmA,b0/nrmBC]);
        [~,s_ac,v]=svd([as0/nrmA;c0/nrmBC]);

        Delta=(diag(s_ab)*diag(s_ac)')./abs(w'*v).^2;
        [Delta_min,kmin]=min(Delta(:));
        [i,j]=ind2sub([n,n],kmin);
        v=v(:,j);w=w(:,i);

        T=[null(w'),v];
        a0=T\a0*T;b0=T\b0;c0=c0*T;
        n=n-1;
        a0=a0(1:n,1:n);b0=b0(1:n,:);c0=c0(:,1:n);

        aux=sTest*eye(n)-a0;
        gap=(norm(c0/aux,1)*nrmA+nrmBC)*(norm(aux\b0,1)*nrmA+nrmBC)*Delta_min/fTest;


        if gap<RelTol*nrmh0

            a=a0;b=b0;c=c0;
        else

            break;
        end
    end
