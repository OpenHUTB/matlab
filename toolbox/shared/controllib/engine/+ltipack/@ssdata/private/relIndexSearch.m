function r=relIndexSearch(a,b,c,d,e,Ts,W1,W2,tol,rFDI)



    zeroTol=1e3*eps;
    nx=size(a,1);
    nu=size(d,2);
    ncw1=size(W1,2);
    ncw2=size(W2,2);
    ncw=ncw1+ncw2;
    if isempty(e)
        e=eye(nx);
    end
    enorm=norm(e,1);


    c1=W1'*c;c2=W2'*c;d1=W1'*d;d2=W2'*d;



    if isinf(rFDI)||nx==0||norm(b,1)==0||norm(c1,1)+norm(c2,1)==0
        r=rFDI;return
    end


    aux=norm([d1;d2],1);
    if aux>0
        c1=c1/aux;c2=c2/aux;d1=d1/aux;d2=d2/aux;
    end


    tau=sqrt(norm([c1;c2],1)/norm(b,1));
    b=tau*b;c1=c1/tau;c2=c2/tau;


    BP=[b,zeros(nx,ncw2)];
    SP=[zeros(nx,nu),c2'];
    RP=[zeros(nu),d2';d2,eye(ncw2)];
    NULL=zeros(nx);
    if Ts==0
        t=ricpack.scaleR(norm(a,1),norm(b,1),1);
        [V1,V2]=ricpack.CARE('a',a,t*BP,[],NULL,t^2*RP,t*SP,e);
    else
        t=ricpack.scaleR(norm(a,1)+enorm,norm(b,1),1);
        [V1,V2]=ricpack.DARE('a',a,t*BP,NULL,t^2*RP,t*SP,e);
    end



    if min(svd(V2))<zeroTol
        r=Inf;return
    end

    [Y1,Y2]=localRowCompress(e,V1,zeroTol);
    nP=size(Y1,2);
    if nP==0

        r=rFDI;return
    end


    Accel=true;
    SGN=+1;
    rShift=max(tol,1e-6);
    r0=rFDI*(1+rShift);
    rMin=r0;rMax=Inf;
    yMin=NaN;yMax=NaN;dyLast=Inf;
    r=r0;
    NRIC=1;
    BP=[b,zeros(nx,ncw)];
    hw=ctrlMsgUtils.SuspendWarnings;%#ok<NASGU> % CARE/DARE may warn
    while rMax>r0&&rMax>rMin*(1+tol)+zeroTol

        SP=[zeros(nx,nu),c1',r*c2'];
        aux=[d1;r*d2];
        RP=[zeros(nu),aux';aux,diag([-ones(ncw1,1);ones(ncw2,1)])];
        if Ts==0
            [U1,U2,~,~,RES]=ricpack.CARE('a',a,t*BP,[],NULL,t^2*RP,t*SP,e);
        else
            [U1,U2,~,~,RES]=ricpack.DARE('a',a,t*BP,NULL,t^2*RP,t*SP,e);
        end
        NRIC=NRIC+1;
        if isempty(U1)||max(RES)>1e-2

            rShift=10*rShift;
            r0=rFDI*(1+rShift);
            rMin=r0;r=r0;
            continue
        end

        if Accel




            tau=localMaxGenEig(-U2'*e*V1,U1'*e'*V2,zeroTol*enorm);
            rNext=sqrt(max(0,tau+r^2));
            if tau>0
                rMin=r;
                if SGN<0
                    rMax=rNext;
                end
            else
                rMax=r;
                if SGN>0
                    rMin=rNext;
                end
            end
            if SGN*tau<0||tau*(rMin+rMax-2*rNext)<0

                Accel=false;
                r=(rMin+rMax)/2;

            else
                r=rNext;
                SGN=-SGN;
            end
        else

            F=U2;G=e*U1;
            if nP<nx

                [Q,~]=qr(F'*Y2);
                F=Y1'*F*Q(:,nx-nP+1:nx);
                G=Y1'*G*Q(:,nx-nP+1:nx);
            end
            emin=min(real(eig(F,G)));
            if emin>0
                rMax=r;yMax=emin;
            else
                rMin=r;yMin=emin;
            end

            if isnan(yMin)||isnan(yMax)||yMin==0||(yMax<-yMin&&yMax-yMin>dyLast/2)

                r=(rMin+rMax)/2;
            else
                tMin=rMin^2;tMax=rMax^2;
                tLIN=tMin-yMin*(tMax-tMin)/(yMax-yMin);
                if yMax>=-yMin
                    r=sqrt(tLIN);

                else

                    r=sqrt(2*tLIN-tMax);
                    dyLast=yMax-yMin;
                end
            end
        end
    end


    if rMax>r0
        r=rMax;
    else

        r=rFDI;
    end





    function tau=localMaxGenEig(A,B,zeroTol)


        nx=size(B,1);
        [U,S,V]=svd(B);
        rk=sum(diag(S)>zeroTol);
        if rk<nx
            U=U(:,1:rk);
            V=V(:,1:rk);
            tau=max(real(eig(U'*A*V,U'*B*V)));
        else
            tau=max(real(eig(A,B)));
        end

        function[Y1,Y2]=localRowCompress(e,V1,zeroTol)

            nx=size(V1,2);
            [~,S,Y]=svd(V1');
            rk=sum(diag(S)>zeroTol);
            if rk<nx&&~isequal(e,eye(nx))
                [Y,~]=qr(e*Y(:,1:rk));
            end
            Y1=Y(:,1:rk);
            Y2=Y(:,rk+1:nx);

