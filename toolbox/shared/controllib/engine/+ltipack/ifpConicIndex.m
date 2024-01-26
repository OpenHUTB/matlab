function[tMax,fMax,heigs]=ifpConicIndex(a,b,c,d,e,Ts,tol,tStop,fTest,fBand,RealFlag)

    Ts=abs(Ts);
    nx=size(a,1);
    DescFlag=~isempty(e);
    heigs=zeros(0,1);

    ni=nargin;
    if ni<8
        tStop=-Inf;
    end
    if ni<9
        fTest=zeros(0,1);
    end
    if ni<11
        RealFlag=(isreal(a)&&isreal(b)&&isreal(c)&&isreal(d)&&isreal(e));
    end
    if ni<10||isempty(fBand)
        fBand=[0,pi/Ts];
    else
        fBand(2)=min(fBand(2),pi/Ts);
        if fBand(1)>fBand(2)
            error(message('Control:analysis:getPeakGain3'))
        end
    end
    tMax=Inf;
    fMax=fBand(1);

    if nx==0
        tMax=min(eig(d+d'))/2;return
    end

    aa=a;bb=b;cc=c;ee=e;
    if norm(tril(aa,-2),1)+norm(tril(ee,-2),1)>0
        if DescFlag

            [aa,ee,q,z]=hess(aa,ee);
            bb=q*bb;
            cc=cc*z;
        else

            [u,aa]=hess(aa);
            bb=u'*bb;
            cc=cc*u;
        end
    end

    if RealFlag
        fTest=[fBand(:);fTest(fTest>fBand(1)&fTest<fBand(2))];
    else
        fTest=[fBand(:);-fBand(:);fTest(abs(fTest)>fBand(1)&abs(fTest)<fBand(2))];
    end
    [h,fTest]=evalFreqResp(aa,bb,cc,d,ee,Ts,fTest,fBand);
    for ct=1:numel(fTest)

        hw=h(:,:,ct);
        tw=min(eig(hw+hw'))/2;
        if tw<=tStop
            tMax=tw;fMax=fTest(ct);return
        elseif tw<tMax
            tMax=tw;fMax=fTest(ct);
        end
    end

    if tMax==Inf
        return
    end

    tau=norm(d,1)+norm(b,1)^2/(1+norm(a,1));

    OFFSET=0.001;
    if isempty(e)
        e=eye(nx);
    end
    for iter=1:30
        tMax0=tMax;
        dt=tol*tau*(OFFSET+abs(tMax/tau));
        tH=tMax-dt;
        [heigs,w_acc]=localHamTest(a,b,c,d,e,Ts,tH);
        if RealFlag
            heigs=heigs(imag(heigs)>=0);
        end
        ws=pickTestFreqs(heigs,w_acc,fBand,fMax);
        if isempty(ws)
            break
        end
        [h,ws]=evalFreqResp(aa,bb,cc,d,ee,Ts,ws,fBand);
        for ct=1:numel(ws)
            hw=h(:,:,ct);
            tw=min(eig(hw+hw'))/2;
            if tw<=tStop
                tMax=tw;fMax=ws(ct);return
            elseif tw<tMax
                tMax=tw;fMax=ws(ct);
            end
        end

        if tMax>tMax0-dt/10
            break
        end
    end


    function[heigs,w_acc]=localHamTest(a,b,c,d,e,Ts,t)

        nx=size(a,1);nu=size(d,1);
        R=d+d'-(2*t)*eye(nu);
        if Ts==0
            [ta,td]=ltipack.scalePencil(norm(a,1),norm(b,1),norm(R,1));
            [alpha,beta,w_acc]=ltipack.eigSHH(ta^2*a,ta^2*e,zeros(nx),zeros(nx),...
            td^2*R,(ta*td)*b,(ta*td)*c');
            idx=find(beta~=0);
            heigs=alpha(idx)./beta(idx);
        else


            [ta,td]=ltipack.scalePencil(norm(a,1)+norm(e,1),norm(b,1),norm(R,1));
            bs=(ta*td)*b;
            [alpha,beta,w_acc]=ltipack.eigSHH(ta^2*(a-e),ta^2*(a+e),zeros(nx),zeros(nx),...
            td^2*R,bs,(ta*td)*c',bs);

            Ts=abs(Ts);
            idx=find(abs(beta)>100*eps*abs(alpha)&beta+alpha~=0&beta-alpha~=0);
            heigs=(log(beta(idx)+alpha(idx))-log(beta(idx)-alpha(idx)))/Ts;
            w_acc=ltipack.getAccLims(w_acc,Ts);
        end