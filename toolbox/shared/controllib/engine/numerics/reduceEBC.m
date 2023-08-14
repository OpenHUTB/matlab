function[a,b,c,e]=reduceEBC(a,b,c,e,tol,EBCScale)
















    ns=size(a,1);


    while ns>0

        [q,~,~,rkBE]=rrqrf([b/EBCScale(2),e/EBCScale(1)],tol,1);
        rho=ns-rkBE;
        if rho==0
            break
        end
        qL=q(:,1:rkBE);


        [q,~]=qr(a'*q(:,rkBE+1:ns));
        qR=q(:,rho+1:ns);
        b=qL'*b;c=c*qR;a=qL'*a*qR;e=qL'*e*qR;
        ns=rkBE;
    end


    while ns>0

        [q,~,~,rkCE]=rrqrf([c'/EBCScale(3),e'/EBCScale(1)],tol,1);
        rho=ns-rkCE;
        if rho==0
            break
        end
        qR=q(:,1:rkCE);

        [q,~]=qr(a*q(:,rkCE+1:ns));
        qL=q(:,rho+1:ns);
        b=qL'*b;c=c*qR;a=qL'*a*qR;e=qL'*e*qR;
        ns=rkCE;
    end
