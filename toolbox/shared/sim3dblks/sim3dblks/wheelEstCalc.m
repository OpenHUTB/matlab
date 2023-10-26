function[xdotW,delta]=wheelEstCalc(Xdot,Ydot,psi,r,wb,delta0)

    whlLim=pi/3;
    xdotLim=.1;
    xdot=Xdot*cos(psi)+Ydot*sin(psi);
    ydot=Xdot*sin(psi)+Ydot*cos(psi);
    [~,rabs]=automltirediv0prot(r,1e-3);
    Rabs=abs(xdot)./rabs;
    delta=atan2(wb,max(Rabs,wb))*sign(r).*sign(xdot);
    if abs(xdot) < xdotLim
        delta=delta0;
    else
        if delta>whlLim
            delta=whlLim;
        elseif delta<-whlLim
            delta=-whlLim;
        end
    end
    xdotW=double(xdot*cos(abs(delta)));
end


function[y,yabs]=automltirediv0prot(u,tol)
    coder.allowpcode('plain')

    yabs=abs(u);
    ytolinds=yabs<tol;
    yabs(ytolinds)=2.*tol(ytolinds)./(3-(yabs(ytolinds)./tol(ytolinds)).^2);
    yneginds=u<0;
    y=yabs;
    y(yneginds)=-yabs(yneginds);
end