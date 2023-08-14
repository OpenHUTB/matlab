function[rMin,fMin,heigs]=...
    relConicIndex(a,b,c,d,e,Ts,W1,W2,tol,rStop,fTest,fBand,RealFlag)

































    Ts=abs(Ts);
    [nx,nu]=size(b);
    nw1=size(W1,2);
    nw2=size(W2,2);
    nw=nw1+nw2;
    DescFlag=~isempty(e);
    heigs=zeros(0,1);

    if nw2<nu

        rMin=Inf;fMin=NaN;return
    end


    ni=nargin;
    if ni<10
        rStop=Inf;
    end
    if ni<11
        fTest=zeros(0,1);
    end
    if ni<13
        RealFlag=(isreal(a)&&isreal(b)&&isreal(c)&&isreal(d)&&...
        isreal(e)&&isreal(W1)&&isreal(W2));
    end
    if ni<12||isempty(fBand)
        fBand=[0,pi/Ts];
    else
        fBand(2)=min(fBand(2),pi/Ts);
        if fBand(1)>fBand(2)
            error(message('Control:analysis:getPeakGain3'))
        end
    end
    rMin=0;
    fMin=fBand(1);



    cc=[W1,W2]'*c;dd=[W1,W2]'*d;
    if nx==0||norm(b,1)==0||norm(cc,1)==0
        rMin=ltipack.util.gsvmax(dd(1:nw1,:),dd(nw1+1:nw,:),0);return
    end



    aa=a;bb=b;ee=e;
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


    [h,fTest,~,hscale]=evalFreqResp(aa,bb,cc,dd,ee,Ts,fTest,fBand);
    for ct=1:numel(fTest)

        rw=ltipack.util.gsvmax(h(1:nw1,:,ct),h(nw1+1:nw,:,ct),hscale(ct));
        if isnan(rw)

            rMin=Inf;fMin=NaN;return
        elseif rw>=rStop
            rMin=rw;fMin=fTest(ct);return
        elseif rw>rMin
            rMin=rw;fMin=fTest(ct);
        end
    end



    if rMin==0
        return
    end


    for iter=1:30

        rMin0=rMin;
        r=(1+tol)*rMin;




        [heigs,w_acc]=HamConicTest(a,b,c,d,e,Ts,[],W1,W2,-1,r);
        if RealFlag

            heigs=heigs(imag(heigs)>=0);
        end


        ws=pickTestFreqs(heigs,w_acc,fBand,fMin);
        if isempty(ws)
            break
        end


        [h,ws,~,hscale]=evalFreqResp(aa,bb,cc,dd,ee,Ts,ws,fBand);
        for ct=1:numel(ws)
            rw=ltipack.util.gsvmax(h(1:nw1,:,ct),h(nw1+1:nw,:,ct),hscale(ct));
            if isnan(rw)
                rMin=Inf;fMin=NaN;return
            elseif rw>=rStop
                rMin=rw;fMin=ws(ct);return
            elseif rw>rMin
                rMin=rw;fMin=ws(ct);
            end
        end



        if rMin<rMin0*(1+tol/10)
            break
        end
    end
