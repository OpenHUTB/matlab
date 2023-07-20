function Dr=balred(D,r,BalData,MatchDC)











    Ts=D.Ts;


    nns=BalData.Split(1);
    ns=BalData.Split(2);
    if r+nns==order(D)

        Dr=D;return
    end


    Rr=BalData.Rr;
    Ro=BalData.Ro;



    a=BalData.as;
    b=BalData.bs;
    c=BalData.cs;
    e=BalData.es;
    EXPLICIT=isempty(e);


    if MatchDC

        if EXPLICIT

            [w,~]=qr(Rr'*BalData.v(:,1:r));
            [z,~]=qr(Ro'*BalData.u(:,1:r));
            w1=w(:,1:r);w2=z(:,r+1:ns);
            z1=z(:,1:r);z2=w(:,r+1:ns);
        else
            [w1,~]=qr(Rr'*BalData.v(:,1:r),0);
            [z1,~]=qr(Ro'*BalData.u(:,1:r),0);
            [w2,~]=qr(Rr'*BalData.v(:,r+1:ns),0);
            [z2,~]=qr(Ro'*BalData.u(:,r+1:ns),0);
        end
        if nns>0
            w1=blkdiag(eye(nns),w1);
            [w2,~]=qr([BalData.R*w2;w2],0);

            [z1,~]=qr([zeros(nns,r),eye(nns);z1,BalData.L'],0);
            z1=z1(:,[r+1:r+nns,1:r]);
            z2=[zeros(nns,ns-r);z2];
        end
        w=[w1,w2];
        z=[z1,z2];

        if EXPLICIT
            er=blkdiag(z1'*w1,zeros(ns-r));
        else
            er=blkdiag(z1'*e*w1,zeros(ns-r));

        end
        ar=z'*a*w;
        if Ts~=0
            ix2=nns+r+1:nns+ns;
            if EXPLICIT
                ar(ix2,ix2)=ar(ix2,ix2)-z2'*w2;
            else
                ar(ix2,ix2)=ar(ix2,ix2)-z2'*e*w2;
            end
        end
        br=z'*b;
        cr=c*w;
    else

        [w1,~]=qr(Rr'*BalData.v(:,1:r),0);
        [z1,~]=qr(Ro'*BalData.u(:,1:r),0);
        if nns>0
            w1=blkdiag(eye(nns),w1);
            [z1,~]=qr([zeros(nns,r),eye(nns);z1,BalData.L'],0);
            z1=z1(:,[r+1:r+nns,1:r]);
        end
        ar=z1'*a*w1;
        br=z1'*b;
        cr=c*w1;
        if EXPLICIT
            er=z1'*w1;
        else
            er=z1'*e*w1;
        end
    end


    dr=BalData.d;
    if EXPLICIT||MatchDC


        [ar,br,cr,dr,er]=localElimAV(ar,br,cr,dr,er,norm(b,1),norm(c,inf),EXPLICIT);
    end
    Dr=ltipack.ssdata(ar,br,cr,dr,er,Ts);
    if BalData.Transpose
        Dr=Dr.';
    end
    Dr.Delay=D.Delay;



    function[a,b,c,d,e]=localElimAV(a,b,c,d,e,bScale,cScale,EXPLICIT)









        if any(e,'all')
            [a,b,c,e,rkE]=minreal_inf(a,b,c,e,[1,bScale,cScale]);
        else

            rkE=0;
        end
        if rkE<size(a,1)

            [a,b,c,d,e]=elimAV(a,b,c,d,e,rkE,eps^(1/3));
            EDIAG=true;
        else
            EDIAG=false;
        end

        if EXPLICIT&&rkE>0&&rkE==size(a,1)

            if EDIAG

                s=1./sqrt(diag(e));
                a=a.*(s*s');b=s.*b;c=c.*s';
            else
                [a,b]=ltipack.utElimE(a,b,e);
            end
            e=[];
        end
