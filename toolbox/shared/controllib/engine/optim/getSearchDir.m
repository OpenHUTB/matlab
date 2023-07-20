function d=getSearchDir(E,fval,Q,bfgs,dmin,dmax,TraceOptions)


































    np=size(E,1);

    if bfgs

        [d,~,qpinfo]=localMinimaxQP(Q,-E',-fval,dmin,dmax,1);

        fact=1;
        while(qpinfo>0||hasInfNaN(d))&&eps*fact<1
            if TraceOptions.Debug
                fprintf('bfgs mode, regularizing qp (rcond(Q) = %.3g)\n',rcond(Q));
            end
            Q(1:np+1:end)=max(fact*eps*Q(1,1),Q(1:np+1:end));
            [d,~,qpinfo]=localMinimaxQP(Q,-E',-fval,dmin,dmax,1);
            fact=fact*10;
        end
        if qpinfo>0&&TraceOptions.Debug
            fprintf('bfgs mode, qp failure code %d\n',qpinfo);
        end

    else

        [d,~,qpinfo]=localMinimaxQP(Q,-E',-fval,[],[],0,1);

        if qpinfo>0&&TraceOptions.Debug
            fprintf('phase 2, qp failure code %d\n',qpinfo);
        end
    end


    function[x,u,info]=localMinimaxQP(c,a,b,xl,xu,ichol,hes,q)



















































        ni=nargin;
        n=size(a,2);
        if ni<4,xl=[];end
        if ni<5,xu=[];end
        if ni<6,ichol=0;end
        if ni<7,hes=0;end
        if ni<8,q=[];end
        [x,u,info]=qp_nsopt(c,[],a,b,0,xl,xu,ichol,1,hes,q);
        if isempty(x)

            x=zeros(n,1);
        else
            x=x(1:n);
            if hes>=2&&nargout>1
                p=size(c,1);
                if p<n
                    u(1:p)=[];
                end
            end
        end
