function[x,status,feasflag,lambda]=qpipmw(Q,c,A,b,E,f,x,options)










































































%#codegen
    coder.allowpcode('plain');

    ONE=ones('like',c);
    ONEINT=ones('like',options.MaxIterations);
    ZEROINT=zeros('like',options.MaxIterations);

    feastol=options.ConstraintTolerance;
    opttol=options.OptimalityTolerance;
    mutol=options.ComplementarityTolerance;
    zerotol=options.StepTolerance;
    maxiter=options.MaxIterations;


    bmax=10*ONE;
    bmin=1*ONE;
    delta=0.1*ONE;
    gamma=0.1*ONE;
    a0=.99995*ONE;


    Kmax=5*ONEINT;

    m=cast(size(A,1),'like',ONEINT);
    n=cast(size(A,2),'like',ONEINT);
    p=cast(numel(f),'like',ONEINT);
    iter=ZEROINT;
    feasflag=true;
    status=ONEINT;


    [x,y,z,s]=get_init(Q,c,A,b,E,f,x);
    lambda=struct('ineqlin',z,'eqlin',y);
    if m==ZEROINT
        feasflag=all(abs(E*x-f)<=feastol);
        if~feasflag
            status=-ONEINT;
        end
        return
    end

    dz=ones(m,1,'like',ONE);
    while iter<maxiter
        [rQ,rE,rA,rS]=kkt_residual(Q,c,A,b,E,f,x,y,z,s);
        mu=-sum(rS)/cast(m,'like',ONE);

        feasflag=all([rA;abs(rE)]<=feastol);
        if(feasflag&&all(abs(rQ)<=opttol)&&mu<=mutol)||all(abs(dz)<=zerotol)
            break
        end

        iter=iter+ONEINT;

        [L,U,pp]=kkt_fact(Q,A,E,z,s);


        [dx,dy,dz,ds]=kkt_solve(A,E,rQ,rE,rA,rS,z,s,L,U,pp);
        az=alpha_max(z,dz,zerotol);
        as=alpha_max(s,ds,zerotol);

        as=min(az,as);az=as;

        k=ZEROINT;
        stop=false;
        while k<Kmax&&~stop
            k=k+ONEINT;

            zt=z+az*dz;
            st=s+as*ds;
            rS=-zt.*st;
            mu1=-sum(rS)/cast(m,'like',ONE);
            sigma=(mu1/mu)^3;


            v=-rS;
            vt=max(min(v,bmax*sigma*mu),bmin*sigma*mu);
            rS=vt-v;
            rS=max(rS,-bmax*sigma*mu);

            [dxc,dyc,dzc,dsc]=kkt_solve(A,E,zeros(n,1),zeros(p,1),zeros(m,1),rS,z,s,L,U,pp);

            dz1=dz+dzc;
            ds1=ds+dsc;
            dx1=dx+dxc;
            dy1=dy+dyc;

            az1=alpha_max(z,dz1,zerotol);
            as1=alpha_max(s,ds1,zerotol);

            as1=min(az1,as1);az1=as1;

            if k>ONEINT&&(az1<az+gamma*delta||as1<as+gamma*delta)
                stop=true;
            else

                az=az1;
                as=as1;
                dx=dx1;
                dy=dy1;
                ds=ds1;
                dz=dz1;
            end
        end

        as=a0*as;
        az=a0*az;

        as=min(az,as);az=as;

        dx=as*dx;
        dy=az*dy;
        dz=az*dz;
        ds=as*ds;

        x=x+dx;
        y=y+dy;
        z=z+dz;
        s=s+ds;

    end

    if iter==maxiter
        status=ZEROINT;
    else
        if~feasflag
            status=-ONEINT;
        else
            status=iter+ONEINT;
        end
    end

    lambda.ineqlin=z;
    lambda.eqlin=y;

    function[rQ,rE,rA,rS]=kkt_residual(Q,c,A,b,E,f,x,y,z,s)

        rQ=-(Q*x+E'*y+A'*z+c);
        rE=E*x-f;
        rA=A*x+s-b;
        rS=-z.*s;

        function[L,U,pp]=kkt_fact(Q,A,E,z,s)


            [L,U,pp]=lu([Q+A'*diag(z./s)*A,E';E,zeros(size(E,1))],'vector');

            function[dx,dy,dz,ds]=kkt_solve(A,E,rQ,rE,rA,rS,z,s,L,U,pp)

                m=cast(size(A,1),'int32');
                n=cast(size(A,2),'int32');
                p=cast(size(E,1),'int32');

                b=[rQ-A'*((z.*rA+rS)./s);-rE];

                if coder.target('MATLAB')&&issparse(A)
                    dxdy=zeros(n+p+m,1);
                    dxdy(pp)=L'\(U\(L\b(pp,:)));
                else
                    dxdy=linsolve(U,linsolve(L,b(pp,:),struct('LT',true)),struct('UT',true));
                end


                dx=dxdy(1:n);
                dy=dxdy(n+1:n+p);
                dz=z./s.*(A*dx+rA)+rS./s;
                ds=(rS-dz.*s)./z;

                function a=alpha_max(z,dz,tol)



                    a=ones('like',z);
                    for i=1:numel(dz)
                        if dz(i)<0
                            a=min(a,(tol-z(i))/dz(i));
                        end
                    end

                    function[x,y,z,s]=get_init(Q,c,A,b,E,f,x)


                        ONE=ones('like',c);
                        ZERO=zeros('like',c);

                        m=cast(size(A,1),'int32');
                        p=cast(size(E,1),'int32');

                        y=zeros(p,1,'like',ONE);
                        z=ones(m,1,'like',ONE);
                        s=ones(m,1,'like',ONE);

                        if m==int32(0)

                            [L,U,pp]=kkt_fact(Q,A,E,z,s);
                            [x,y]=kkt_solve(A,E,-c,-f,zeros(0,1),zeros(0,1),z,s,L,U,pp);
                            return
                        end

                        [rQ,rE,rA,rS]=kkt_residual(Q,c,A,b,E,f,x,y,z,s);
                        [L,U,pp]=kkt_fact(Q,A,E,z,s);
                        [~,~,dz,ds]=kkt_solve(A,E,rQ,rE,rA,rS,z,s,L,U,pp);


                        u=max(ZERO,-z-dz);
                        w=max(ZERO,-s-ds);
                        b1=.1*ONE;
                        b2=1*ONE;

                        z=z+dz+b1+b2*u;
                        s=s+ds+b1+b2*w;

