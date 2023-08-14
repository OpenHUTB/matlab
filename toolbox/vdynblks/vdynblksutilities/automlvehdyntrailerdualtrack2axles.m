function[yOut,FTotal,MTotal,FOut,Fhz,FTire,Fg,wheelInfo,stateDer,status]=automlvehdyntrailerdualtrack2axles(delta_f,delta_r,mu,a,c,d,dh_f,dh_r,hl_f,hl_r,h,hh_f,hh_r,w,m,NF,NR,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_r,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,Cy_f,Cy_r,stateVec)
%#codegen
    coder.allowpcode('plain')











    xdot=stateVec(1);
    ydot=stateVec(2);
    r=stateVec(4);

    Xwheel_fl=sqrt(a.^2+(w(1)./2).^2);
    Xwheel_rl=sqrt(c.^2+(w(2)./2).^2);

    Vwheel_fl=sqrt((ydot-Xwheel_fl.*r).^2+xdot.^2);
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

    alfa_fl=atan2((ydot-a*r),abs(xdot_p+w(1)./2.*r))-delta_fl.*tanh(4.*xdot);
    alfa_fr=atan2((ydot-a*r),abs(xdot_p-w(1)./2.*r))-delta_fr.*tanh(4.*xdot);
    alfa_rl=atan2((ydot-c*r),abs(xdot_p+w(2)./2.*r))-delta_rl.*tanh(4.*xdot);
    alfa_rr=atan2((ydot-c*r),abs(xdot_p-w(2)./2.*r))-delta_rr.*tanh(4.*xdot);

    Fz=zeros(1,4);
    for iterCnt=0:10

        if iterCnt==0

            [F,~]=Calc3DOF2AxleTrailerZReactionForces(0,xdot,0,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,c,dh_f,dh_r);

            Fz_fl=F(1);
            Fz_fr=F(2);
            Fz_rl=F(3);
            Fz_rr=F(4);

            Fzinit=automlsatfunc([Fz_fl,Fz_fr,Fz_rl,Fz_rr],0);
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
            xddot=ydot.*r+(Fx_fl+Fx_fr+Fx_rl+Fx_rr+Fh_f(1)+Fh_r(1)-m*g.*sin(gamma)+F_ext(1))./m;
        end

        yddot=-xdot.*r+(Fy_fl+Fy_fr+Fy_rl+Fy_rr+F_ext(2)+Fh_f(2)+Fh_r(2))./m;

        rdot=(-a.*(Fy_fl+Fy_fr)-c.*(Fy_rl+Fy_rr)+dh_f.*Fh_f(2)-dh_r.*Fh_r(2)+w(1)./2.*(Fx_fl-Fx_fr)...
        +w(2)./2.*(Fx_rl-Fx_rr)+M_ext(3)+Mh_f(3)+Mh_r(3)-Fh_f(1)*(hl_f-d)-Fh_r(1)*(hl_r-d))./Izz;

        [F,Fhz]=Calc3DOF2AxleTrailerZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,c,dh_f,dh_r);

        Fz_fl=F(1);
        Fz_fr=F(2);
        Fz_rl=F(3);
        Fz_rr=F(4);

        Fz=automlsatfunc([Fz_fl,Fz_fr,Fz_rl,Fz_rr],0);
        maxFerr=max(abs(Fz-Fzinit));

    end
    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_fl;alfa_fr;alfa_rl;alfa_rr;Vwheel_fl;Vwheel_fr;Vwheel_rl;Vwheel_rr];
    yOut=[xddot;yddot;rdot];
    FOut=[Fx_fl;Fy_fl;Fz(1);Fx_fr;Fy_fr;Fz(2);Fx_rl;Fy_rl;Fz(3);Fx_rr;Fy_rr;Fz(4)];
    FTire=[Fx_fl.*2./NF;Fy_fl.*2./NF;Fz(1).*2./NF;Fx_fr.*2./NF;Fy_fr.*2./NF;Fz(2).*2./NF;Fx_rl.*2./NR;Fy_rl.*2./NR;Fz(3).*2./NR;Fx_rr.*2./NR;Fy_rr.*2./NR;Fz(4).*2./NR];
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



function[F,Fhz_f]=Calc3DOF2AxleTrailerZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,Fext,Mext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,c,dh_f,dh_r)

    w1=w(1);
    w2=w(2);

    x1=-a;
    x2=-c;

    Fhx_f=Fh_f(1);
    Fhy_f=Fh_f(2);

    Fhx_r=Fh_r(1);
    Fhy_r=Fh_r(2);
    Fhz_r=Fh_r(3);

    Mhx_f=Mh_f(1);
    Mhy_f=Mh_f(2);

    Mhx_r=Mh_r(1);
    Mhy_r=Mh_r(2);

    Fextx=Fext(1);
    Fexty=Fext(2);
    Fextz=Fext(3);

    Mextx=Mext(1);
    Mexty=Mext(2);

    B1=h*m*yddot-Mhx_f-Mhx_r-Fexty*h-Fhy_f*hh_f-Fhy_r*hh_r-Fhz_r*hl_r-Mextx+h*m*r*xdot;
    B2=Fextx*h-Mhy_f-Mhy_r-Fhz_r*dh_r-Mexty+Fhx_f*hh_f+Fhx_r*hh_r-h*m*xddot+h*m*r*ydot-g*h*m*sin(gamma);
    B3=Fextz+Fhz_r+g*m*cos(gamma);

    F=[-(B2*dh_f*w1-4*B1*x1^2-6*B1*x2^2-4*B2*d*dh_f-4*B2*dh_f*hl_f-4*B1*dh_f^2+B2*dh_f*w2+4*B2*d*x2+2*B1*dh_f*x1+6*B1*dh_f*x2+4*B2*hl_f*x2-2*B2*w1*x1+B2*w1*x2-2*B2*w2*x1+B2*w2*x2+6*B1*x1*x2+4*B3*d*dh_f^2-B3*dh_f^2*w1-B3*dh_f^2*w2+2*B3*d*x1^2+2*B3*d*x2^2-2*B3*hl_f*x1^2-4*B3*hl_f*x2^2-B3*w1*x2^2-B3*w2*x2^2+B3*w1*x1*x2+B3*w2*x1*x2-4*B3*d*dh_f*x2+2*B3*dh_f*hl_f*x1+2*B3*dh_f*hl_f*x2+B3*dh_f*w1*x1+B3*dh_f*w2*x1-4*B3*d*x1*x2+2*B3*hl_f*x1*x2)/(4*(dh_f^2*w1+dh_f^2*w2+d*x1^2+d*x2^2+hl_f*x1^2+hl_f*x2^2+w1*x1^2+w1*x2^2+w2*x1^2+w2*x2^2-dh_f*w1*x1-dh_f*w1*x2-dh_f*w2*x1-dh_f*w2*x2-2*d*x1*x2-2*hl_f*x1*x2-w1*x1*x2-w2*x1*x2));
    -(4*B1*dh_f^2+4*B1*x1^2+2*B1*x2^2+4*B2*d*dh_f+4*B2*dh_f*hl_f+B2*dh_f*w1+B2*dh_f*w2-4*B2*d*x1-6*B1*dh_f*x1-2*B1*dh_f*x2-4*B2*hl_f*x1-2*B2*w1*x1+B2*w1*x2-2*B2*w2*x1+B2*w2*x2-2*B1*x1*x2-4*B3*d*dh_f^2-B3*dh_f^2*w1-B3*dh_f^2*w2-2*B3*d*x1^2-2*B3*d*x2^2+2*B3*hl_f*x1^2-B3*w1*x2^2-B3*w2*x2^2+B3*w1*x1*x2+B3*w2*x1*x2+4*B3*d*dh_f*x1-2*B3*dh_f*hl_f*x1-2*B3*dh_f*hl_f*x2+B3*dh_f*w1*x1+B3*dh_f*w2*x1+4*B3*d*x1*x2+2*B3*hl_f*x1*x2)/(4*(dh_f^2*w1+dh_f^2*w2+d*x1^2+d*x2^2+hl_f*x1^2+hl_f*x2^2+w1*x1^2+w1*x2^2+w2*x1^2+w2*x2^2-dh_f*w1*x1-dh_f*w1*x2-dh_f*w2*x1-dh_f*w2*x2-2*d*x1*x2-2*hl_f*x1*x2-w1*x1*x2-w2*x1*x2));
    -(B2*dh_f*w1-6*B1*x1^2-4*B1*x2^2-4*B2*d*dh_f-4*B2*dh_f*hl_f-4*B1*dh_f^2+B2*dh_f*w2+4*B2*d*x1+6*B1*dh_f*x1+2*B1*dh_f*x2+4*B2*hl_f*x1+B2*w1*x1-2*B2*w1*x2+B2*w2*x1-2*B2*w2*x2+6*B1*x1*x2+4*B3*d*dh_f^2-B3*dh_f^2*w1-B3*dh_f^2*w2+2*B3*d*x1^2+2*B3*d*x2^2-4*B3*hl_f*x1^2-2*B3*hl_f*x2^2-B3*w1*x1^2-B3*w2*x1^2+B3*w1*x1*x2+B3*w2*x1*x2-4*B3*d*dh_f*x1+2*B3*dh_f*hl_f*x1+2*B3*dh_f*hl_f*x2+B3*dh_f*w1*x2+B3*dh_f*w2*x2-4*B3*d*x1*x2+2*B3*hl_f*x1*x2)/(4*(dh_f^2*w1+dh_f^2*w2+d*x1^2+d*x2^2+hl_f*x1^2+hl_f*x2^2+w1*x1^2+w1*x2^2+w2*x1^2+w2*x2^2-dh_f*w1*x1-dh_f*w1*x2-dh_f*w2*x1-dh_f*w2*x2-2*d*x1*x2-2*hl_f*x1*x2-w1*x1*x2-w2*x1*x2));
    -(4*B1*dh_f^2+2*B1*x1^2+4*B1*x2^2+4*B2*d*dh_f+4*B2*dh_f*hl_f+B2*dh_f*w1+B2*dh_f*w2-4*B2*d*x2-2*B1*dh_f*x1-6*B1*dh_f*x2-4*B2*hl_f*x2+B2*w1*x1-2*B2*w1*x2+B2*w2*x1-2*B2*w2*x2-2*B1*x1*x2-4*B3*d*dh_f^2-B3*dh_f^2*w1-B3*dh_f^2*w2-2*B3*d*x1^2-2*B3*d*x2^2+2*B3*hl_f*x2^2-B3*w1*x1^2-B3*w2*x1^2+B3*w1*x1*x2+B3*w2*x1*x2+4*B3*d*dh_f*x2-2*B3*dh_f*hl_f*x1-2*B3*dh_f*hl_f*x2+B3*dh_f*w1*x2+B3*dh_f*w2*x2+4*B3*d*x1*x2+2*B3*hl_f*x1*x2)/(4*(dh_f^2*w1+dh_f^2*w2+d*x1^2+d*x2^2+hl_f*x1^2+hl_f*x2^2+w1*x1^2+w1*x2^2+w2*x1^2+w2*x2^2-dh_f*w1*x1-dh_f*w1*x2-dh_f*w2*x1-dh_f*w2*x2-2*d*x1*x2-2*hl_f*x1*x2-w1*x1*x2-w2*x1*x2))];

    Fhz_f=(2*B1*x1^2+2*B1*x2^2-2*B2*dh_f*w1-2*B2*dh_f*w2+B2*w1*x1+B2*w1*x2+B2*w2*x1+B2*w2*x2-4*B1*x1*x2-2*B3*d*x1^2-2*B3*d*x2^2-B3*w1*x1^2-B3*w1*x2^2-B3*w2*x1^2-B3*w2*x2^2+B3*dh_f*w1*x1+B3*dh_f*w1*x2+B3*dh_f*w2*x1+B3*dh_f*w2*x2+4*B3*d*x1*x2)/(2*(dh_f^2*w1+dh_f^2*w2+d*x1^2+d*x2^2+hl_f*x1^2+hl_f*x2^2+w1*x1^2+w1*x2^2+w2*x1^2+w2*x2^2-dh_f*w1*x1-dh_f*w1*x2-dh_f*w2*x1-dh_f*w2*x2-2*d*x1*x2-2*hl_f*x1*x2-w1*x1*x2-w2*x1*x2));

    if Fh_f(3)~=0

        Fhz_f=Fhz_f+Fh_f(3);

        B1=h*m*yddot-Mhx_f-Mhx_r-Fexty*h-Fhy_f*hh_f-Fhy_r*hh_r-Fhz_f*hl_f-Fhz_r*hl_r-Mextx+h*m*r*xdot;
        B2=Fhz_f*dh_f-Mhy_f-Mhy_r-Mexty-Fhz_r*dh_r+Fextx*h+Fhx_f*hh_f+Fhx_r*hh_r-h*m*xddot+h*m*r*ydot-g*h*m*sin(gamma);
        B3=Fextz+Fhz_f+Fhz_r+g*m*cos(gamma);

        F=[(B2*w1+B2*w2+2*B1*x1-2*B1*x2-2*B3*d*x1+2*B3*d*x2-B3*w1*x2-B3*w2*x2)/(2*(w1+w2)*(x1-x2));
        (B2*w1+B2*w2-2*B1*x1+2*B1*x2+2*B3*d*x1-2*B3*d*x2-B3*w1*x2-B3*w2*x2)/(2*(w1+w2)*(x1-x2));
        -(B2*w1+B2*w2-2*B1*x1+2*B1*x2+2*B3*d*x1-2*B3*d*x2-B3*w1*x1-B3*w2*x1)/(2*(w1+w2)*(x1-x2));
        -(B2*w1+B2*w2+2*B1*x1-2*B1*x2-2*B3*d*x1+2*B3*d*x2-B3*w1*x1-B3*w2*x1)/(2*(w1+w2)*(x1-x2))];

    end

end