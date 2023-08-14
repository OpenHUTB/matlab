function[z,p,k]=zpk_minreal_inf(am,bm,cm,dm,em,Ts)

















    n=size(am,1)-1;
    if n==0

        z=zeros(0,1);p=zeros(0,1);k=dm-bm*cm/am;
    else

        [v,w,tau]=ltipack.householder(bm);
        p=-tau;
        aa=am-v*(w'*am);
        ee=em-v*(w'*em);
        g=aa(1,1:n);h=aa(1,n+1);a=aa(2:n+1,1:n);f=aa(2:n+1,n+1);
        m=ee(1,1:n);e=ee(2:n+1,1:n);
        c=cm(1,1:n);q=cm(1,n+1);


        dN=dm*h-p*q;cN=dm*g-p*c;
        [W,~]=qr([e;dm*m]);
        w12=W(1:n,n+1);w22=W(n+1,n+1);
        [z,kN]=ltipack.sszero(a,f,w22'*cN+w12'*a,w22'*dN+w12'*f,e,Ts,'norefine');
        kN=kN/w22';



        q22=-w(n+1)*v(1)';
        [p,kD]=ltipack.sszero(a,f,am(n+1,1:n),am(n+1,n+1),e,Ts,'norefine');
        kD=kD/q22;




        if nargout>2
            k=kN/kD;
            fact=ltipack.adjustGain(am,bm,cm,dm,em,Ts,z,p,k);
            k=k*fact;
            if isreal(am)&&isreal(bm)&&isreal(cm)&&isreal(dm)&&isreal(em)
                k=real(k);
            end
        end
    end
