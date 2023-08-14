function t=dirIndexSearch(a,b,c,d,e,Ts,M0,W3,tol,tMin,tFDI)







    zeroTol=1e3*eps;
    [nx,nu]=size(b);
    [nrw3,ncw3]=size(W3);
    if isempty(e)
        e=eye(nx);
    end
    NULL=zeros(nx);



    if tFDI<=tMin||nx==0||norm(b,1)==0||norm(W3'*c,1)==0
        t=tFDI;return
    elseif tFDI<-1e8

        t=-Inf;return
    end


    [~,W1,W2]=ltipack.getSectorData(M0,[]);
    W12=[W1,W2];
    sgn12=[ones(size(W1,2),1);-ones(size(W2,2),1)];


    c12=W12'*c;d12=W12'*d;c3=W3'*c;d3=W3'*d;
    aux=norm([d3;d12],1);
    if aux>0
        c12=c12/aux;d12=d12/aux;c3=c3/aux;d3=d3/aux;
    end


    Ypos=localGetLimit(a,b,c12,d12,c3,d3,e,sgn12,Ts);
    if~Ypos
        t=-Inf;return
    end


    tau=sqrt(norm([c12;c3],1)/norm(b,1));
    b=tau*b;c12=c12/tau;c3=c3/tau;
    if Ts==0
        ts=ricpack.scaleR(norm(a,1),norm(b,1),1);
    else
        ts=ricpack.scaleR(norm(a,1)+norm(e,1),norm(b,1),1);
    end


    tShift=max(tol,1e-6)*(1+abs(tFDI));
    t0=tFDI-tShift;
    tMin=tMin-0.1*(1+abs(tMin));
    tMax=t0;
    yMin=NaN;yMax=NaN;dyLast=Inf;
    t=t0;
    NRIC=1;
    BP=[b,zeros(nx,ncw3+nrw3)];
    while tMin<t0&&tMax>tMin+tol*(1+abs(tMax))
        if t>0
            sgn3=-1;r=sqrt(t);
        else
            sgn3=+1;r=sqrt(-t);
        end

        SP=[zeros(nx,nu),r*c3',c12'];
        aux=[r*d3;d12];
        RP=[zeros(nu),aux';aux,diag([sgn3*ones(ncw3,1);-sgn12])];
        if Ts==0
            [U1,U2,~,~,RES]=ricpack.CARE('a',a,ts*BP,[],NULL,ts^2*RP,ts*SP,e);
        else
            [U1,U2,~,~,RES]=ricpack.DARE('a',a,ts*BP,NULL,ts^2*RP,ts*SP,e);
        end
        if isempty(U1)||max(RES)>1e-2

            tShift=10*tShift;
            t0=tMax-tShift;
            tMax=t0;t=t0;
            continue
        end
        NRIC=NRIC+1;



        F=U2;G=e*U1;
        [~,sv,Y]=svd(U1');
        nP=sum(diag(sv)>zeroTol);
        if nP<nx

            if nP==0

                t=tFDI;return
            elseif~isequal(e,eye(nx))
                [Y,~]=qr(e*Y(:,1:nP));
            end
            Y1=Y(:,1:nP);
            [QY,~]=qr(F'*Y(:,nP+1:nx));
            F=Y1'*F*QY(:,nx-nP+1:nx);
            G=Y1'*G*QY(:,nx-nP+1:nx);
        end
        emin=min(real(eig(F,G)));
        if emin>0
            tMin=t;yMin=emin;
        else
            tMax=t;yMax=emin;
        end

        if tMin==-Inf

            t=tMax-max(1,abs(tMax));
        elseif isnan(yMin)||isnan(yMax)||(yMin<-yMax&&yMin-yMax>dyLast/2)

            t=(tMin+tMax)/2;
        else
            tLIN=tMax-yMax*(tMax-tMin)/(yMax-yMin);
            if yMin>=-yMax
                t=tLIN;

            else

                t=2*tLIN-tMin;
                dyLast=yMin-yMax;
            end
        end
        if tMax<-1e8

            t=-Inf;return
        end
    end


    if tMin<t0
        t=tMin;
    else

        t=tFDI;
    end






    function Ypos=localGetLimit(a,b,c12,d12,c3,d3,e,sgn12,Ts)




        if~isequal(e,eye(size(a)))
            a=e\a;b=e\b;
        end
        rtol=1e-6;inftol=1e12;



        nc3=norm(c3,1);
        nd3=norm(d3,1);
        if nc3>0&&nd3>0
            tau=sqrt(norm(a,1)*norm(b,1)/nc3/nd3);
        elseif nc3>0
            tau=norm(a,1)/nc3;
        else
            tau=norm(b,1)/nd3;
        end
        c3=tau*c3;d3=tau*d3;

        Scale=max(norm(a,1),norm(c3,1));
        tau=Scale/max(norm(b,1),norm(d3,1));
        b=tau*b;d12=tau*d12;d3=tau*d3;
        zeroTol=rtol*Scale;
        niter=0;
        while~isempty(d3)
            niter=niter+1;

            [V,sv,W12]=svd(d3);
            n=min(size(d3));
            sv=diag(sv(1:n,1:n));
            rk=sum(sv>zeroTol);
            W2=W12(:,rk+1:end);
            V1=V(:,1:rk);V2=V(:,rk+1:end);
            if isempty(V2)

                break
            end


            [~,sv,W]=svd(V2'*c3,0);
            n=min(size(sv));
            sv=diag(sv(1:n,1:n));
            rk=sum(sv>zeroTol);
            W2=W(:,1:rk);W1=W(:,rk+1:end);
            if isempty(W2)

                d3=V1'*d3;c3=V1'*c3;continue
            elseif isempty(W1)
                Ypos=true;return
            end


            c3=[W2'*a*W1;V1'*c3*W1];
            d3=[W2'*b;V1'*d3];
            a=W1'*a*W1;
            b=W1'*b;
            c12=c12*W1;
        end

        [m,n]=size(d3);
        if m>0

            W1=W12(:,1:rk);
            sv=sv(1:rk);
            d3ic3=W1*lrscale(V1'*c3,1./sv,[]);

            [p,nY]=size(c12);
            a=a-b*d3ic3;
            b=b*W2;
            c12=c12-d12*d3ic3;
            d12=d12*W2;
            BY=[zeros(nY,n-m),c12'];
            SY=[b,zeros(nY,p)];
            RY=[zeros(n-m),d12';d12,-diag(sgn12)];
            if Ts==0
                [U1,U2]=ricpack.CARE('s',a',BY,[],zeros(nY),RY,SY,[]);
            else
                [U1,U2]=ricpack.DARE('s',a',BY,zeros(nY),RY,SY,[]);
            end
            eY=real(eig(U2,U1));
            eY=eY(abs(eY)>rtol);
            Ypos=all(eY>0&eY<inftol);
        else
            Ypos=true;
        end