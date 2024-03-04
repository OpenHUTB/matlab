function sys=fitRationalD(y,w,Ts,N,wt,diagFlag)

    if Ts~=0
        y([1,end])=abs(y([1,end])).*sign(real(y([1,end])));
    end

    try
        [z,p,k]=controllib.internal.fitRational.fitRational(w,y(:),[],Ts,wt(:),N);
    catch
        sys=zpk(double(diagFlag),'Ts',Ts);return
    end
    z=z{1};

    if diagFlag
        if Ts==0
            ip=find(real(p)>0);iz=find(real(z)>0);
            p(ip,:)=-p(ip,:);z(iz,:)=-z(iz,:);
            if rem(numel(iz)-numel(ip),2)==1
                k=-k;
            end
        else
            ip=find(abs(p)>1);iz=find(abs(z)>1);
            k=k*prod(-z(iz,:))/prod(-p(ip,:));
            p(ip,:)=1./p(ip,:);z(iz,:)=1./z(iz,:);
        end
        z=localMinDamping(z,Ts,1e-3);
        p=localMinDamping(p,Ts,1e-3);
    else
        z=localMinDamping(z,Ts,1e-1);
        p=localMinDamping(p,Ts,1e-1);
    end

    sys=zpk(z,p,k,Ts);



    function r=localMinDamping(r,Ts,zetaMin)
        [~,zeta]=damp(r,Ts);
        id=find(abs(zeta)<zetaMin);
        for ct=1:numel(id)
            SIN=sqrt(1-zetaMin^2);
            r0=r(id(ct));
            REAL=isreal(r0);
            if Ts~=0
                r0=log(r0)/Ts;
            end
            r0=abs(r0).*complex(zetaMin*sign(real(r0)),SIN*sign(imag(r0)));
            if Ts~=0
                r0=exp(r0*Ts);
                if REAL
                    r0=-abs(r0);
                end
            end

            r(id(ct))=r0;
        end

