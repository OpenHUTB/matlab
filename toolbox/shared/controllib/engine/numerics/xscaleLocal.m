function[a,b,c,e,sr,sl,info]=xscaleLocal(a,b,c,d,e,Ts,w)












    nx=size(a,1);
    ne=size(e,1);
    Ts=abs(Ts);
    if Ts==0
        s=complex(0,w);
    else
        s=exp(complex(0,w*Ts));
    end


    [br,cr,dr]=ltipack.util.pruneIO(b,c,d);


    if ne==0
        [beta,gamma]=ltipack.util.safeMdivide(s*eye(nx)-a,br,cr);
    else
        [beta,gamma]=ltipack.util.safeMdivide(s*e-a,br,cr);
    end
    h=dr+cr*beta;

    if all(isfinite(h),'all')


        betav=sum(abs(beta),2);
        gammav=sum(abs(gamma),1);
        bv=sum(abs(br),2);
        cv=sum(abs(cr),1);
        P=abs(a);
        Q=betav*gammav;
        if isempty(e)

            R=betav*cv+bv*gammav;
            lb=trace(R)+norm(dr,'fro');
            sr=quadgp1(P,Q/lb,R/lb);
            sl=1./sr;
        else

            P=P+abs(s)*abs(e);
            R1=bv*gammav;
            R2=betav*cv;
            lb=trace(R1)+trace(R2)+norm(dr,'fro');
            [sl,sr]=quadgp2(P,Q/lb,[],[],R1/lb,R2/lb);
        end


        [InitialSens,nh]=ltipack.util.frsensLocal(a,br,cr,dr,e,s,h,beta,gamma);


        a=a.*(sl*sr');
        b=sl.*b;
        c=c.*sr';
        if ne>0
            e=e.*(sl*sr');
        end


        bnorm=norm(b,1);
        cnorm=norm(c,1);
        if bnorm>0&&cnorm>0
            s=pow2(round(log2(bnorm/cnorm)/2));
            b=b/s;sl=sl/s;
            c=c*s;sr=sr*s;
        end


        ScaledSens=ltipack.util.frsensLocal(a,sl.*br,cr.*sr',dr,e,s,h,sr.\beta,gamma./sl');
    else

        [a,b,c,e,sr]=aebalance(a,b,c,e,'safebal','noperm');
        sl=1./sr;
        InitialSens=Inf;
        ScaledSens=Inf;
        nh=Inf;
    end

    info=struct('Initial',InitialSens,'Final',ScaledSens,'Gain',nh);
