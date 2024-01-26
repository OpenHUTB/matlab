function[tMax,fMax,heigs]=...
    dirConicIndex(a,b,c,d,e,Ts,M,W,tol,tStop,fTest,fBand,RealFlag)

    Ts=abs(Ts);
    nx=size(a,1);
    DescFlag=~isempty(e);
    heigs=zeros(0,1);
    zeroTol=1e3*eps;
    N=W*W';

    ni=nargin;
    if ni<10
        tStop=-Inf;
    end
    if ni<11
        fTest=zeros(0,1);
    end
    if ni<13
        RealFlag=(isreal(a)&&isreal(b)&&isreal(c)&&isreal(d)&&...
        isreal(e)&&isreal(M)&&isreal(W));
    end
    if ni<12||isempty(fBand)
        fBand=[0,pi/Ts];
    else
        fBand(2)=min(fBand(2),pi/Ts);
        if fBand(1)>fBand(2)
            error(message('Control:analysis:getPeakGain3'))
        end
    end
    tMax=Inf;
    fMax=fBand(1);

    if nx==0||norm(b,1)==0||(norm(W'*c,1)==0&&norm([c,d]'*M*c,1)==0)
        tMax=ltipack.getTmax(M,W*W',d);return
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
    [h,fTest,hmag,hscale]=evalFreqResp(aa,bb,cc,d,ee,Ts,fTest,fBand);
    for ct=1:numel(fTest)

        if hmag(ct)<zeroTol*hscale(ct)
            tw=NaN;
        else
            tw=ltipack.getTmax(M,N,h(:,:,ct));
        end
        if isnan(tw)
            tMax=-Inf;fMax=NaN;return
        elseif tw<=tStop
            tMax=tw;fMax=fTest(ct);return
        elseif tw<tMax
            tMax=tw;fMax=fTest(ct);
        end
    end

    if tMax==Inf
        return
    end

    OFFSET=0.001;
    for iter=1:30
        tMax0=tMax;
        dt=tol*(OFFSET+abs(tMax));
        tH=tMax-dt;

        if tH>0
            sgn=+1;r=sqrt(tH);
        else
            sgn=-1;r=sqrt(-tH);
        end
        [heigs,w_acc]=HamConicTest(a,b,c,d,e,Ts,M,[],W,sgn,r);
        if RealFlag

            heigs=heigs(imag(heigs)>=0);
        end
        ws=pickTestFreqs(heigs,w_acc,fBand,fMax);
        if isempty(ws)
            break
        end
        [h,ws,hmag,hscale]=evalFreqResp(aa,bb,cc,d,ee,Ts,ws,fBand);
        for ct=1:numel(ws)
            if hmag(ct)<zeroTol*hscale(ct)
                tw=NaN;
            else
                tw=ltipack.getTmax(M,N,h(:,:,ct));
            end
            if isnan(tw)
                tMax=-Inf;fMax=NaN;return
            elseif tw<=tStop
                tMax=tw;fMax=ws(ct);return
            elseif tw<tMax
                tMax=tw;fMax=ws(ct);
            end
        end

        if tMax>tMax0-dt/10
            break
        end
    end
