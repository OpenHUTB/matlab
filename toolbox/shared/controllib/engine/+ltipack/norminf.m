function[gpeak,fpeak,heigs]=...
    norminf(a,b,c,d,e,Ts,tol,gStop,fTest,fBand,RealFlag)






























    Ts=abs(Ts);
    nx=size(a,1);
    DescFlag=~isempty(e);
    heigs=zeros(0,1);


    ni=nargin;
    if ni<8
        gStop=Inf;
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
    gpeak=0;fpeak=fBand(1);


    bnorm=norm(b,1);
    cnorm=norm(c,1);
    if nx==0||bnorm==0||cnorm==0
        gpeak=norm(d);return
    end
    tau=sqrt(cnorm/bnorm);
    b=tau*b;c=c/tau;



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
    if Ts>0
        s=exp(complex(0,Ts*fTest));
    else
        s=complex(0,fTest);
    end
    [h,~,gFro]=ssfresp(aa,bb,cc,d,ee,s);
    [~,is]=sort(gFro,'descend');
    for ct=1:numel(fTest)
        cts=is(ct);

        if gFro(cts)>gpeak
            w=fTest(cts);
            gw=norm(h(:,:,cts));
            if gw>=gStop
                gpeak=gw;fpeak=w;return;
            elseif gw>gpeak
                gpeak=gw;fpeak=w;
            end
        end
    end
    if gpeak==0


        return
    end


    for iter=1:30

        gpeak0=gpeak;
        g=(1+tol)*gpeak;


        [heigs,w_acc]=HamGainTest(a,b,c,d,e,Ts,g,false);
        if RealFlag

            heigs=heigs(imag(heigs)>=0);
        end


        ws=pickTestFreqs(heigs,w_acc,fBand,fpeak);
        if isempty(ws)
            break
        end


        if Ts>0
            s=exp(complex(0,Ts*ws));
        else
            s=complex(0,ws);
        end
        [hws,~,gFro]=ssfresp(aa,bb,cc,d,ee,s);
        for ct=1:numel(ws)
            if gFro(ct)>gpeak
                w=ws(ct);
                gw=norm(hws(:,:,ct));
                if gw>=gStop
                    gpeak=gw;fpeak=w;return;
                elseif gw>gpeak
                    gpeak=gw;fpeak=w;
                end
            end
        end



        if gpeak<gpeak0*(1+tol/10)
            break
        end
    end