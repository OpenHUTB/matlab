function[yOut,FTotal,MTotal,FOut,FTire,Fg,wheelInfo,stateDer,status]=automlvehdyndualtrack(delta_f,delta_r,mu,a,b,h,d,w,m,Nf,Nr,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_r,F_ext,M_ext,Fh,Mh,Cy_f,Cy_r,dh,hl,hh,stateVec)
%#codegen
    coder.allowpcode('plain')









    xdot=stateVec(1);
    ydot=stateVec(2);
    r=stateVec(4);

    Xwheel_fl=sqrt(a.^2+(w(1)./2).^2);
    Xwheel_rl=sqrt(b.^2+(w(2)./2).^2);
    Vwheel_fl=sqrt((ydot+Xwheel_fl.*r).^2+xdot.^2);
    Vwheel_fr=Vwheel_fl;
    Vwheel_rl=sqrt((ydot-Xwheel_rl.*r).^2+xdot.^2);
    Vwheel_rr=Vwheel_rl;

    grade=0;
    gamma=pi/180*grade;
    [xdot_p,~]=automldiv0protect(xdot,xdot_tol);
    delta_fl=delta_f(1);
    delta_fr=delta_f(2);
    delta_rl=delta_r(1);
    delta_rr=delta_r(2);
    alfa_fl=atan2((ydot+a*r),abs(xdot_p+w(1)./2.*r))-delta_fl.*tanh(4.*xdot);
    alfa_fr=atan2((ydot+a*r),abs(xdot_p-w(1)./2.*r))-delta_fr.*tanh(4.*xdot);
    alfa_rl=atan2((ydot-b*r),abs(xdot_p+w(2)./2.*r))-delta_rl.*tanh(4.*xdot);
    alfa_rr=atan2((ydot-b*r),abs(xdot_p-w(2)./2.*r))-delta_rr.*tanh(4.*xdot);
    Fz=zeros(1,4);
    for iterCnt=0:10
        if iterCnt==0
            FzCalc=Calc3DOF2AxleZReactionForces(0,xdot,0,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh,Mh,h,hh,hl,a,b,dh);
            Fzinit=automlsatfunc(2*FzCalc,0);
        else
            Fzinit=Fz;
        end
        switch inputMode
        case 1
            Fx_fl=0;
            Fx_fr=0;
            Fx_rl=0;
            Fx_rr=0;
            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;
            Fy_rl=-Cy_r(1)./2.*alfa_rl.*mu(2,1).*Fzinit(3)./Fznom;
            Fy_rr=-Cy_r(2)./2.*alfa_rr.*mu(2,2).*Fzinit(4)./Fznom;
            [Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);
        case 2
            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);
            Fx_rl=F_r(1,1);
            Fx_rr=F_r(2,1);
            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;
            Fy_rl=-Cy_r(1)./2.*alfa_rl.*mu(2,1).*Fzinit(3)./Fznom;
            Fy_rr=-Cy_r(2)./2.*alfa_rr.*mu(2,2).*Fzinit(4)./Fznom;
            [Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);
        case 3
            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);
            Fx_rl=F_r(1,1);
            Fx_rr=F_r(2,1);
            Fy_fl=F_f(1,2);
            Fy_fr=F_f(2,2);
            Fy_rl=F_r(1,2);
            Fy_rr=F_r(2,2);
        otherwise
            Fx_fl=0;
            Fx_fr=0;
            Fx_rl=0;
            Fx_rr=0;
            Fy_fl=0;
            Fy_fr=0;
            Fy_rl=0;
            Fy_rr=0;
        end
        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fx_fl+Fx_fr+Fx_rl+Fx_rr-m.*g.*sin(gamma)+F_ext(1)+Fh(1))./m;
        end
        yddot=-xdot.*r+(Fy_fl+Fy_fr+Fy_rl+Fy_rr+F_ext(2)+Fh(2))./m;
        rdot=(a.*(Fy_fl+Fy_fr)-b.*(Fy_rl+Fy_rr)+w(1)./2.*(Fx_fl-Fx_fr)...
        +w(2)./2.*(Fx_rl-Fx_rr)+M_ext(3)+Mh(3)-Fh(1)*(hl-d)-Fh(2)*dh)./Izz;

        FzCalc=Calc3DOF2AxleZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh,Mh,h,hh,hl,a,b,dh);
        Fz=automlsatfunc(2*FzCalc,0);
        maxFerr=max(abs(Fz-Fzinit));

    end
    stateDer=[xddot;yddot;r;rdot];
    wheelInfo=[alfa_fl;alfa_fr;alfa_rl;alfa_rr;Vwheel_fl;Vwheel_fr;Vwheel_rl;Vwheel_rr];
    yOut=[xddot;yddot;rdot];
    FOut=[Fx_fl;Fy_fl;Fz(1);Fx_fr;Fy_fr;Fz(2);Fx_rl;Fy_rl;Fz(3);Fx_rr;Fy_rr;Fz(4)];
    FTire=[Fx_fl./Nf;Fy_fl./Nf;Fz(1)./Nf./2;Fx_fr./Nf;Fy_fr./Nf;Fz(2)./Nf./2;Fx_rl./Nr;Fy_rl./Nr;Fz(3)./Nr./2;Fx_rr./Nr;Fy_rr./Nr;Fz(4)./Nr./2].*2;
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    Fg=[0;0;m.*g];
    status=maxFerr;
end
function[Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat,Fytire_sat)
    [Fx_flt,Fy_flt]=automlvehdynftiresat(Fx_fl,Fy_fl,Fxtire_sat(1),Fytire_sat(1),1);
    [Fx_frt,Fy_frt]=automlvehdynftiresat(Fx_fr,Fy_fr,Fxtire_sat(2),Fytire_sat(2),1);
    [Fx_rlt,Fy_rlt]=automlvehdynftiresat(Fx_rl,Fy_rl,Fxtire_sat(3),Fytire_sat(3),1);
    [Fx_rrt,Fy_rrt]=automlvehdynftiresat(Fx_rr,Fy_rr,Fxtire_sat(4),Fytire_sat(4),1);

    [Fx_fl,Fy_fl]=mysincos2(Fx_flt,Fy_flt,delta_fl);

    [Fx_fr,Fy_fr]=mysincos2(Fx_frt,Fy_frt,delta_fr);

    [Fx_rl,Fy_rl]=mysincos2(Fx_rlt,Fy_rlt,delta_rl);

    [Fx_rr,Fy_rr]=mysincos2(Fx_rrt,Fy_rrt,delta_rr);

end

function[x,y]=mysincos2(u1,u2,theta)
    x=u1.*cos(theta)-u2.*sin(theta);
    y=u1.*sin(theta)+u2.*cos(theta);
end

function Fz=Calc3DOF2AxleZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,Fext,Mext,Fh,Mh,h,hh,hl,a,b,dh)



    Fz=zeros(1,4);

    B1=Fh(2)*(h-hh)-Mh(1)-Mext(1)-Fh(3)*(hl-d)-h*(Fext(2)+Fh(2)-m*(yddot+r*xdot));
    B2=h*(Fext(1)+Fh(1)-m*(xddot-r*ydot)-g*m*sin(gamma))-Mh(2)-Fh(3)*dh-Fh(1)*(h-hh)-Mext(2);
    B3=-Fext(3)-Fh(3)-g*m*cos(gamma);

    Fz(1,1)=-(2*B1*a+2*B1*b+B2*w(1)+B2*w(2)+2*B3*a*d+2*B3*b*d-B3*b*w(1)-B3*b*w(2))/(2*(a+b)*(w(1)+w(2)));
    Fz(1,2)=(2*B1*a+2*B1*b-B2*w(1)-B2*w(2)+2*B3*a*d+2*B3*b*d+B3*b*w(1)+B3*b*w(2))/(2*(a+b)*(w(1)+w(2)));
    Fz(1,3)=-(2*B1*a+2*B1*b-B2*w(1)-B2*w(2)+2*B3*a*d+2*B3*b*d-B3*a*w(1)-B3*a*w(2))/(2*(a+b)*(w(1)+w(2)));
    Fz(1,4)=(2*B1*a+2*B1*b+B2*w(1)+B2*w(2)+2*B3*a*d+2*B3*b*d+B3*a*w(1)+B3*a*w(2))/(2*(a+b)*(w(1)+w(2)));


    Fz=-Fz;

end