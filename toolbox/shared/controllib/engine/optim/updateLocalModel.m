function[R,p,s,y]=updateLocalModel(R0,p0,x1,x2,g1,g2,TraceOptions)













    s=x2-x1;
    y=g2-g1;
    tau=y'*s;

    if tau>0
        n=length(s);
        sqrt_tau=sqrt(tau);
        u_tau=(R0*s(p0))/sqrt_tau;
        y_tau=y(p0)/sqrt_tau;



        CCF=min(1,max(0.1,1/norm(u_tau)));



        M(1:n+1,p0)=[CCF*(R0-u_tau*y_tau');y_tau'];
        [~,R,p]=qr(M,0);


        idx=find(diag(R)<0);
        R(idx,:)=-R(idx,:);
    else

        R=R0;p=p0;
        if TraceOptions.Debug&&any(s)
            fprintf('CHOLDFP: Skipped Cholesky update to maintain positive definiteness\n');
        end
    end
