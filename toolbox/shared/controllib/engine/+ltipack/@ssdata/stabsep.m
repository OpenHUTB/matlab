function[D1,D2,WARN,SepInfo,TL,TR]=stabsep(D,Options)




    if hasInternalDelay(D)
        throw(ltipack.utNoDelaySupport('stabsep',D.Ts,'internal'))
    end
    a=D.a;b0=D.b;c0=D.c;d=D.d;e=D.e;Ts=D.Ts;
    nx=size(a,1);
    EXPLICIT=isempty(e);
    REAL=isreal(a)&&isreal(e);



    [br,cr,dr,uproj,yproj]=ltipack.util.pruneIO(b0,c0,d);
    RELACC=pow2(-39);
    if D.Scaled
        [w,emax]=computeMaxError(a,br,cr,dr,e,Ts,RELACC,Options.SepTol);
        sL=1;sR=1;
    else
        [a,b0,c0,e,sR,sL,Info]=xscale(a,b0,c0,d,e,Ts);
        w=Info.Freq;


        emax=max(RELACC,Options.SepTol*Info.ScaledAcc).*Info.Gain;
    end
    if Ts==0
        s=complex(0,w);
    else
        s=exp(complex(0,w*Ts));
    end


    SCALE=1;
    if EXPLICIT
        [z,a]=schur(a);q=z';
        p=ordeig(a);
    else
        if REAL
            [a,e,q,z]=qz(a,e,'real');
        else
            [a,e,q,z]=qz(a,e);
        end


        enorm=norm(e,'fro');
        if Ts==0
            e=cleanPolesAtInfinity(e,10*eps*enorm);
        end
        p=ordeig(a,e);
        if enorm>0
            SCALE=norm(a,'fro')/enorm;
        end
    end


    if Options.wantStable()
        if Ts==0
            selectD2=~(isfinite(p)&real(p)+Options.Offset*max(1,abs(imag(p)))<0);
        else
            selectD2=(abs(p)>=1-Options.Offset);
        end
    else
        if Ts==0
            selectD2=~(isfinite(p)&real(p)-Options.Offset*max(1,abs(imag(p)))>0);
        else
            selectD2=(abs(p)<=1+Options.Offset);
        end
    end


    DONE=false;WARN=false;
    while~DONE

        nx2=sum(selectD2);
        if any(diff(selectD2)>0)
            if EXPLICIT
                [z,a]=ordschur(z,a,selectD2);q=z';
                p=ordeig(a);
            else
                [a,e,q,z]=ordqz(a,e,q,z,selectD2);
                p=ordeig(a,e);
            end
        end


        b=q*b0;c=c0*z;
        [DONE,a2,b2,c2,e2,a1,b1,c1,e1,L,R]=checkSplit(a,b,c,e,nx2,b*uproj,yproj'*c,s,emax);


        if~DONE
            WARN=true;
            selectD2=adjustSplit(p/SCALE,nx2,REAL,EXPLICIT);
        end
    end


    nx1=size(a1,1);
    D1=ltipack.ssdata(a1,b1,c1,d,e1,Ts);
    D1.Delay=D.Delay;

    nx2=size(a2,1);
    D2=ltipack.ssdata(a2,b2,c2,zeros(size(d)),e2,Ts);
    D2.Delay=D.Delay;


    SepInfo=struct('Split',[nx2,nx1],'as',a,'bs',b,'cs',c,'es',e,'L',L,'R',R);


    if nargout>4
        TL=eye(nx);TL(1:nx2,nx2+1:nx)=L;
        TR=eye(nx);TR(1:nx2,nx2+1:nx)=R;
        TL=(TL*q).*sL';
        TR=sR.*(z*TR);
    end