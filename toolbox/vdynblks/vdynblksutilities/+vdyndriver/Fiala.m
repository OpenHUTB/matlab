function Fyf=Fiala(delta,vx,vy,r,Fzf,mu,Calpha,a)
%#codegen
    coder.allowpcode('plain');



    alphaF=atan2(vy+r*a,vx)-delta;
    z=tan(alphaF);

    alphaSL=atan(3*mu*Fzf/Calpha);

    Fyf=(abs(z)<alphaSL).*...
    (-Calpha.*z+Calpha.^2./(3.*mu.*Fzf).*abs(z).*z...
    -Calpha.^3./(27.*mu.^2.*Fzf.^2).*z.^3)...
    +(abs(z)>=alphaSL).*...
    (-mu.*Fzf.*sign(alphaF));
end