function fact=adjustGain(a,b,c,d,e0,Ts,z,p,k)

%#codegen
    CODEGEN=~coder.target('MATLAB');
    if CODEGEN
        coder.allowpcode('plain');
    end
    nx=size(a,1);
    if isempty(e0)
        e=eye(nx,'like',a);
    else
        e=e0;
    end
    anorm=1+norm(a,'fro');

    sTest=localGetTestFreqs(z,p,Ts,anorm/norm(e,'fro'),CODEGEN);
    nf=numel(sTest);
    fact=cast(1,'like',a);
    if nf>0
        tmp=real(d);
        gamma=zeros(nx,1,'like',tmp)+0i;
        hTest=zeros(nf,1,'like',tmp)+0i;
        relacc=zeros(nf,1,'like',tmp);
        if CODEGEN
            for ct=1:nf
                [L,U,perm]=lu(sTest(ct)*e-a,'vector');
                beta=U\(L\b(perm,1));
                gamma(perm)=(c/U)/L;
                h=d+c*beta;
                hTest(ct)=h;
                relacc(ct)=eps*(norm(gamma)*anorm*norm(beta)+abs(d))/abs(h);
            end
        else
            for ct=1:nf
                [L,U,perm]=lu(sTest(ct)*e-a,'vector');
                beta=matlab.internal.math.nowarn.mldivide(U,L\b(perm,1));
                gamma(perm)=matlab.internal.math.nowarn.mrdivide(c,U)/L;
                h=d+c*beta;
                hTest(ct)=h;
                relacc(ct)=eps*(norm(gamma)*anorm*norm(beta)+abs(d))/abs(h);
            end
        end

        [minacc,imin]=min(relacc);
        s=sTest(imin);h=hTest(imin);
        h0=k*prod(s-z)/prod(s-p);
        if h0==0||~isfinite(h0)
            h0=k*exp(sum(log(s-z))-sum(log(s-p)));
        end

        if minacc<1&&abs(h-h0)>relacc(imin)*abs(h)
            fact=h/h0;
        end
    end


    function s=localGetTestFreqs(z,p,Ts,SCALE,CODEGEN)

        ONE=cast(1,'like',SCALE);
        ZERO=0*ONE;
        TWO=2*ONE;
        FOUR=4*ONE;
        PI=pi*ONE;
        NAN=NaN*ONE;
        zerotol=eps(ONE)^0.75;

        if Ts==0
            WMIN=zerotol*SCALE;WMAX=SCALE;FACT=ZERO;
        else

            SCALE=max(TWO,SCALE);
            FACT=(SCALE^2-1)/(SCALE^2+1);
            r=numel(z)-numel(p);
            z=2*[(z-1)./(z+1);ones(-r,1)];z=z(isfinite(z),:);
            p=2*[(p-1)./(p+1);ones(r,1)];p=p(isfinite(p),:);
            WMAX=TWO;WMIN=WMAX*zerotol;
        end
        wz=abs(z);wp=abs(p);w=[wz;wp;WMAX];
        if any(w<WMIN)
            w=sort(w(w>=WMIN&w<=WMAX,:));
        else
            w=[0;sort(w(w<=WMAX,:))];
        end
        nw=numel(w);
        s0=sum(wz==0)-sum(wp==0);

        if CODEGEN
            adh=zeros(nw,1,'like',ONE);
            for ct=1:nw
                adh(ct)=abs(s0+sum(1./(1+wz/w(ct)))-sum(1./(1+wp/w(ct))));
            end
        else
            adh=abs(s0+sum(1./(1+wz'./w),2)-sum(1./(1+wp'./w),2));
        end

        freqs=zeros(nw+25,1,'like',ONE);
        ws=freqs(1);
        adh_min=NAN;
        nf=0;is=1;
        IN=false(nw,1);
        for ct=1:nw
            adh_min=min(adh_min,adh(ct,1));
            if ct==nw||w(ct+1)>1e2*w(ct)
                if is==ct
                    freqs(nf+1)=w(is);nf=nf+1;
                else
                    IN(is:ct,1)=(abs(adh(is:ct,1)-adh_min)<1);
                    for k=is:ct

                        if IN(k)
                            if k==is||~IN(k-1)
                                ws=w(k);
                            end
                            if k==ct||~IN(k+1)
                                we=w(k);
                                ndec=log10(we/ws);
                                nadd=1+ceil(ndec);
                                fact=10^(ndec/(nadd-1));
                                for ctf=1:nadd
                                    freqs(nf+1)=ws;nf=nf+1;ws=ws*fact;
                                end
                            end
                        end
                    end
                end
                is=ct+1;adh_min=NAN;
            end
        end

        r=[z;p];
        wr=abs(r);
        ar=atan2(imag(r),real(r));
        ar(ar<0,1)=ar(ar<0,1)+TWO*PI;
        [ar,is]=sort(ar);
        wr=wr(is,1);

        s=zeros(nf,1,'like',ONE+0i);
        for ct=1:nf
            f=freqs(ct,1);
            aux=FACT*(f/FOUR+ONE/f);
            maxgap=ZERO;
            aopt=PI;
            if Ts~=0&&aux<ONE

                amin=acos(aux);amax=TWO*PI-amin;a1=amin;
                for k=1:numel(r)
                    if abs(wr(k)/f-1)<0.1&&ar(k)>amin&&ar(k)<amax
                        a2=ar(k);
                        if a2-a1>maxgap
                            maxgap=a2-a1;
                            aopt=(a1+a2)/TWO;
                        end
                        a1=a2;
                    end
                end
                if amax-a1>maxgap
                    aopt=(a1+amax)/TWO;
                end
            else

                ix=find(abs(wr/f-1)<0.1);
                if~isempty(ix)
                    a1=ar(ix(1));
                    for k=2:numel(ix)
                        a2=ar(ix(k));
                        if a2-a1>maxgap
                            maxgap=a2-a1;
                            aopt=(a1+a2)/TWO;
                        end
                        a1=a2;
                    end
                    a2=ar(ix(1))+TWO*PI;
                    if a2-a1>maxgap
                        aopt=(a1+a2)/TWO;
                    end
                end
            end
            s(ct)=f*complex(cos(aopt),sin(aopt));
        end

        if Ts~=0

            s=(TWO+s)./(TWO-s);
        end
