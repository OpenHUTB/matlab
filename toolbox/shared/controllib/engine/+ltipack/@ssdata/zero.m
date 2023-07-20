function[z,g]=zero(D)









    Ts=D.Ts;


    if~isempty(D.Delay.Internal)
        if hasDelayDynamics(D,'zero')
            if Ts==0
                warning(message('Control:analysis:ZeroApproximateDelay1'))
            else
                warning(message('Control:analysis:ZeroApproximateDelay2'))
            end
        end
        D=pade(D,inf,inf,0);
    end


    [a0,b,c,d,~,e0]=getABCDE(D);
    if~isfinite(d)
        z=zeros(0,1);g=NaN;return
    end


    [a,b,c,e,xsm]=smreal(a0,b,c,e0);
    if D.Scaled
        WarnID='';
    else
        [a,b,c,e,~,~,info]=xscale(a,b,c,d,e,Ts,'Warn',false);
        WarnID=info.WarnID;
    end


    [a,b,c,e,rkE]=minreal_inf(a,b,c,e);
    if rkE<size(a,1)

        [z,~,g]=zpk_minreal_inf(a,b,c,d,e,Ts);
        if~isfinite(g)
            warning(message('Control:ltiobject:SingularDescriptor'))
            g=NaN;
        end
    else

        [z,g]=ltipack.sszero(a,b,c,d,e,Ts);
        if~isfinite(g)
            warning(message('Control:analysis:zero5'))
            g=NaN;
        end
    end



    insm=find(~xsm);
    if isempty(e0)
        znsm=eig(a0(insm,insm));
    else
        znsm=eig(a0(insm,insm),e0(insm,insm));
    end
    z=[z;znsm(isfinite(znsm))];


    if isfinite(g)&&~isempty(WarnID)
        warning(message(WarnID))
    end
