function p=pole(D,varargin)










    Ts=D.Ts;


    if~isempty(D.Delay.Internal)
        if hasDelayDynamics(D,'pole')

            if Ts==0
                warning(message('Control:analysis:PoleApproximateDelay1'))
            else
                warning(message('Control:analysis:PoleApproximateDelay2'))
            end
        end
        D=pade(D,inf,inf,0);
    end

    [a0,b,c,d,~,e0]=getABCDE(D);


    [a,b,c,e,xsm]=smreal(a0,b,c,e0);


    if isempty(e)

        p=ltipack.sspole(a,[]);
    else

        SingFlag=false;
        if~D.Scaled
            [a,b,c,e,~,~,info]=xscale(a,b,c,d,e,Ts,'Warn',false);
        end

        if isscalar(d)


            [a,~,~,e,rkE]=minreal_inf(a,b,c,e);
            if rkE<size(a,1)

                [p,kp]=localGetPoles(a,e,Ts);
                SingFlag=(kp==0);
            else

                p=ltipack.sspole(a,e);
            end
        else

            ns=size(a,1);
            [a,~,~,e]=minreal_inf(a,zeros(ns,0),zeros(0,ns),e);
            p=ltipack.sspole(a,e);
        end

        if SingFlag
            warning(message('Control:ltiobject:SingularDescriptor'))
        elseif~D.Scaled&&~isempty(info.WarnID)
            warning(message(info.WarnID))
        end
    end



    insm=find(~xsm);
    if isempty(e0)
        pnsm=eig(a0(insm,insm));
    else
        pnsm=eig(a0(insm,insm),e0(insm,insm));
    end
    p=[p;pnsm(isfinite(pnsm))];




    function[p,kp]=localGetPoles(am,em,Ts)

        n=size(am,1)-1;
        a=am(1:n,1:n);f=am(1:n,n+1);g=am(n+1,1:n);h=am(n+1,n+1);
        e=em(1:n,1:n);
        if n==0

            p=zeros(0,1);kp=h;
        else

            [p,kp]=ltipack.sszero(a,f,g,h,e,Ts);
        end
