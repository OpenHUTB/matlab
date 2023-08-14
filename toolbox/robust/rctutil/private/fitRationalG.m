function jgfit=fitRationalG(y,w,Ts,N,wt,diagFlag)













    if diagFlag

        y=imag(y(:));
        wt=abs(wt(:));









        mag=abs(y);
        [peakmag,isign]=max(mag);
        inz=find(mag>1e-3*peakmag);
        ynz=y(inz,:);wnz=w(inz,:);
        idx=find(xor(ynz(2:end)>0,ynz(1:end-1)>0));
        wz=sqrt(wnz(idx,:).*wnz(idx+1,:));
        nz0=numel(wz);
        if Ts==0
            z0=[1i*wz;-1i*wz;0];
            p0=zeros(0,1);
            yz=zpkfresp(z0,p0,1,complex(0,w),true);
        else


            aux=exp(Ts*sqrt(w(1)*w(end)));
            z0=[1;-1];p0=[aux;1/aux];
            for ct=1:nz0
                aux=exp(1i*wz(ct)*Ts);
                z0=[z0;aux;conj(aux)];%#ok<*AGROW>
                p0=[p0;roots([1,-2/real(aux),1])];
            end
            yz=zpkfresp(z0,p0,1,exp(complex(0,w*Ts)),true);
        end
        yz=imag(yz(:));



        k0=sign(y(isign)/yz(isign));



        ix=find(w>0.9*pi/Ts);
        for ct=1:numel(wz)
            ix=[ix;find(abs(1-w/wz(ct))<0.05)];
        end
        if~isempty(ix)
            w(ix)=[];y(ix)=[];yz(ix)=[];wt(ix)=[];
        end


        y=y./yz;
        wt=wt.*abs(yz);
        mag=abs(y);
        if all(mag==0)
            jgfit=ss(0);return
        end
        if Ts==0
            reldegNEED=nz0+1;
        else
            reldegNEED=0;
        end
        np=reldegNEED+N;







        mag=sqrt(mag);wt=sqrt(wt);
        inz=find(mag>0);i1=inz(1);i2=inz(end);
        mag(1:i1-1)=mag(i1);
        mag(i2+1:end)=mag(i2)*(w(i2)./w(i2+1:end)).^reldegNEED;
        inz=find(mag>0);
        w=w(inz,:);mag=mag(inz,:);wt=wt(inz,:);
        y=genphase(mag,w,Ts);










        idx=find(mag>1e-8*max(mag));
        [z,p,k]=controllib.internal.fitRational.fitRational(...
        w(idx),y(idx),[],Ts,wt(idx),{np,reldegNEED});
        z=z{1};
        reldeg=numel(p)-numel(z);


        z=localMinDamping(z,Ts,1e-3);
        p=localMinDamping(p,Ts,1e-3);
        if Ts==0&&reldeg<reldegNEED

            wmax=max(abs(p));
            r=reldegNEED-reldeg;
            p=[p;-wmax(ones(r,1))];
            k=k*wmax^r;
            reldeg=reldegNEED;
        end






        if Ts==0
            k=k0*k^2*(-1)^reldeg;
            z=[z0;z;-z];
            p=[p0;p;-p];
        else
            k=k0*k^2*prod(-z)/prod(-p);
            z=[z0;z;1./z;zeros(reldeg,1)];
            p=[p0;p;1./p];
        end
        jgfit=zpk(z,p,k,Ts);










    else

        [z,p,k]=controllib.internal.fitRational.fitRational(w,y(:),[],Ts,wt(:),N);
        z=localMinDamping(z{1},Ts,1e-1);
        p=localMinDamping(p,Ts,1e-1);
        jgfit=zpk(z,p,k,Ts);
    end




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


