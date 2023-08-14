function[alpha,SPECDATA,SYSDATA,tInfo]=...
    linesearchWF(FUN,f0,X0,d,SLOPE,SPECDATA,SYSDATA,tInfo,OPTS,LSOPT)












































    if~isfinite(SLOPE)||SLOPE>=0
        if OPTS.Trace.Debug
            fprintf('Slope nonnegative, ascent direction \n')
        end
        alpha=0;return
    end


    Smax=min([LSOPT.SMax,2+norm(X0)/norm(d),1e4]);
    Smin=eps*Smax;
    SLOPE1=max(LSOPT.c1*SLOPE,-f0);
    SLOPE2=LSOPT.c2*SLOPE;
    DELTA=LSOPT.Delta;


    alpha=Smin;
    beta=Smax;
    t=min(1,Smax/2);


    FD0=SPECDATA;
    SD0=SYSDATA;
    TI0=tInfo;
    fmin=f0;

    while beta>1.01*alpha
        X=X0+t*d;
        fmax=f0+t*SLOPE1+2*DELTA;
        if fmin<0.9*f0

            fmax=min(fmax,(f0+2*fmin)/3);
        end


        [f,g,FD,SD,TI]=FUN(X,fmax,FD0,SD0,TI0,OPTS);


        if f>=fmax

            beta=t;
        else

            alpha=t;fmin=f;SPECDATA=FD;SYSDATA=SD;tInfo=TI;
            if g'*d>SLOPE2

                break
            end
        end


        if alpha>Smin
            t=sqrt(alpha*beta);
        elseif beta>0.01
            t=beta/2;
        else

            t=max(beta/10,sqrt(alpha*beta));
        end
    end







