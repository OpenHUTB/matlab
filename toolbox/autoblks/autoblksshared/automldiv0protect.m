function[y,yabs]=automldiv0protect(u,tol)
%#codegen




    coder.allowpcode('plain')
    yabs=abs(u);
    ytolinds=yabs<tol;
    yabs(ytolinds)=2.*tol(ytolinds)./(3-(yabs(ytolinds)./tol(ytolinds)).^2);
    yneginds=u<0;
    y=yabs;
    y(yneginds)=-yabs(yneginds);
end