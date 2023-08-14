function[yOut,FTotal,MTotal,FOut,FTire,Fg,wheelInfo,stateDer,status]=automlvehdyndualtrack3axles(delta_f,delta_m,delta_r,mu,a,b,c,d,dh,hl,h,hh,w,m,NF,NM,NR,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_m,F_r,F_ext,M_ext,Fh,Mh,Cy_f,Cy_m,Cy_r,stateVec)
%#codegen
    coder.allowpcode('plain')











    xdot=stateVec(1);
    ydot=stateVec(2);
    r=stateVec(4);

    Xwheel_fl=sqrt(a.^2+(w(1)./2).^2);
    Xwheel_ml=sqrt(b.^2+(w(2)./2).^2);
    Xwheel_rl=sqrt(c.^2+(w(3)./2).^2);

    Vwheel_fl=sqrt((ydot+Xwheel_fl.*r).^2+xdot.^2);
    Vwheel_fr=Vwheel_fl;
    Vwheel_ml=sqrt((ydot-Xwheel_ml.*r).^2+xdot.^2);
    Vwheel_mr=Vwheel_ml;
    Vwheel_rl=sqrt((ydot-Xwheel_rl.*r).^2+xdot.^2);
    Vwheel_rr=Vwheel_rl;

    grade=0;
    gamma=pi/180*grade;
    [xdot_p,~]=automldiv0protect(xdot,xdot_tol);
    delta_fl=delta_f(1);
    delta_fr=delta_f(2);
    delta_ml=delta_m(1);
    delta_mr=delta_m(2);
    delta_rl=delta_r(1);
    delta_rr=delta_r(2);

    alfa_fl=atan2((ydot+a*r),abs(xdot_p+w(1)./2.*r))-delta_fl.*tanh(4.*xdot);
    alfa_fr=atan2((ydot+a*r),abs(xdot_p-w(1)./2.*r))-delta_fr.*tanh(4.*xdot);
    alfa_ml=atan2((ydot-b*r),abs(xdot_p+w(2)./2.*r))-delta_ml.*tanh(4.*xdot);
    alfa_mr=atan2((ydot-b*r),abs(xdot_p-w(2)./2.*r))-delta_mr.*tanh(4.*xdot);
    alfa_rl=atan2((ydot-c*r),abs(xdot_p+w(3)./2.*r))-delta_rl.*tanh(4.*xdot);
    alfa_rr=atan2((ydot-c*r),abs(xdot_p-w(3)./2.*r))-delta_rr.*tanh(4.*xdot);

    Fz=zeros(1,6);
    for iterCnt=0:10

        if iterCnt==0

            F=Calc3DOF3AxleZReactionForces(0,xdot,0,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh,Mh,h,hh,hl,a,b,c,dh);

            Fz_fl=F(1);
            Fz_fr=F(2);
            Fz_ml=F(3);
            Fz_mr=F(4);
            Fz_rl=F(5);
            Fz_rr=F(6);

            Fzinit=automlsatfunc([Fz_fl,Fz_fr,Fz_ml,Fz_mr,Fz_rl,Fz_rr],0);
        else
            Fzinit=Fz;
        end
        switch inputMode
        case 1

            Fx_fl=0;
            Fx_fr=0;
            Fx_ml=0;
            Fx_mr=0;
            Fx_rl=0;
            Fx_rr=0;

            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;
            Fy_ml=-Cy_m(1)./2.*alfa_ml.*mu(2,1).*Fzinit(3)./Fznom;
            Fy_mr=-Cy_m(2)./2.*alfa_mr.*mu(2,2).*Fzinit(4)./Fznom;
            Fy_rl=-Cy_r(1)./2.*alfa_rl.*mu(3,1).*Fzinit(5)./Fznom;
            Fy_rr=-Cy_r(2)./2.*alfa_rr.*mu(3,2).*Fzinit(6)./Fznom;

            [Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_ml,delta_mr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);

        case 2

            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);
            Fx_ml=F_m(1,1);
            Fx_mr=F_m(2,1);
            Fx_rl=F_r(1,1);
            Fx_rr=F_r(2,1);
            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;
            Fy_ml=-Cy_m(1)./2.*alfa_ml.*mu(2,1).*Fzinit(3)./Fznom;
            Fy_mr=-Cy_m(2)./2.*alfa_mr.*mu(2,2).*Fzinit(4)./Fznom;
            Fy_rl=-Cy_r(1)./2.*alfa_rl.*mu(3,1).*Fzinit(5)./Fznom;
            Fy_rr=-Cy_r(2)./2.*alfa_rr.*mu(3,2).*Fzinit(6)./Fznom;

            [Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_ml,delta_mr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);

        case 3

            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);
            Fx_ml=F_m(1,1);
            Fx_mr=F_m(2,1);
            Fx_rl=F_r(1,1);
            Fx_rr=F_r(2,1);
            Fy_fl=F_f(1,2);
            Fy_fr=F_f(2,2);
            Fy_ml=F_m(1,2);
            Fy_mr=F_m(2,2);
            Fy_rl=F_r(1,2);
            Fy_rr=F_r(2,2);

        otherwise
            Fx_fl=0;
            Fx_fr=0;
            Fx_ml=0;
            Fx_mr=0;
            Fx_rl=0;
            Fx_rr=0;
            Fy_fl=0;
            Fy_fr=0;
            Fy_ml=0;
            Fy_mr=0;
            Fy_rl=0;
            Fy_rr=0;
        end

        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fx_fl+Fx_fr+Fx_ml+Fx_mr+Fx_rl+Fx_rr+Fh(1)-m.*g.*sin(gamma)+F_ext(1))./m;
        end

        yddot=-xdot.*r+(Fy_fl+Fy_fr+Fy_ml+Fy_mr+Fy_rl+Fy_rr+F_ext(2)+Fh(2))./m;

        rdot=(a.*(Fy_fl+Fy_fr)-b.*(Fy_ml+Fy_mr)-c.*(Fy_rl+Fy_rr)-dh.*Fh(2)+w(1)./2.*(Fx_fl-Fx_fr)...
        +w(2)./2.*(Fx_ml-Fx_mr)+w(3)./2.*(Fx_rl-Fx_rr)+M_ext(3)+Mh(3)-Fh(1)*(hl-d))./Izz;

        F=Calc3DOF3AxleZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh,Mh,h,hh,hl,a,b,c,dh);

        Fz_fl=F(1);
        Fz_fr=F(2);
        Fz_ml=F(3);
        Fz_mr=F(4);
        Fz_rl=F(5);
        Fz_rr=F(6);

        Fz=automlsatfunc([Fz_fl,Fz_fr,Fz_ml,Fz_mr,Fz_rl,Fz_rr],0);
        maxFerr=max(abs(Fz-Fzinit));

    end
    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_fl;alfa_fr;alfa_ml;alfa_mr;alfa_rl;alfa_rr;Vwheel_fl;Vwheel_fr;Vwheel_ml;Vwheel_mr;Vwheel_rl;Vwheel_rr];
    yOut=[xddot;yddot;rdot];
    FOut=[Fx_fl;Fy_fl;Fz(1);Fx_fr;Fy_fr;Fz(2);Fx_ml;Fy_ml;Fz(3);Fx_mr;Fy_mr;Fz(4);Fx_rl;Fy_rl;Fz(5);Fx_rr;Fy_rr;Fz(6)];
    FTire=[Fx_fl.*2./NF;Fy_fl.*2./NF;Fz(1).*2./NF;Fx_fr.*2./NF;Fy_fr.*2./NF;Fz(2).*2./NF;Fx_ml.*2./NM;Fy_ml.*2./NM;Fz(3).*2./NM;Fx_mr.*2./NM;Fy_mr.*2./NM;Fz(4).*2./NM;Fx_rl.*2./NR;Fy_rl.*2./NR;Fz(5).*2./NR;Fx_rr.*2./NR;Fy_rr.*2./NR;Fz(6).*2./NR];
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    Fg=[0;0;m.*g];
    status=maxFerr;
end


function[Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr]=tire2bodyF(delta_fl,delta_fr,delta_ml,delta_mr,delta_rl,delta_rr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fx_ml,Fy_ml,Fx_mr,Fy_mr,Fx_rl,Fy_rl,Fx_rr,Fy_rr,Fxtire_sat,Fytire_sat)

    [Fx_flt,Fy_flt]=automlvehdynftiresat(Fx_fl,Fy_fl,Fxtire_sat(1),Fytire_sat(1),1);
    [Fx_frt,Fy_frt]=automlvehdynftiresat(Fx_fr,Fy_fr,Fxtire_sat(2),Fytire_sat(2),1);
    [Fx_mlt,Fy_mlt]=automlvehdynftiresat(Fx_ml,Fy_ml,Fxtire_sat(3),Fytire_sat(3),1);
    [Fx_mrt,Fy_mrt]=automlvehdynftiresat(Fx_mr,Fy_mr,Fxtire_sat(4),Fytire_sat(4),1);
    [Fx_rlt,Fy_rlt]=automlvehdynftiresat(Fx_rl,Fy_rl,Fxtire_sat(5),Fytire_sat(5),1);
    [Fx_rrt,Fy_rrt]=automlvehdynftiresat(Fx_rr,Fy_rr,Fxtire_sat(6),Fytire_sat(6),1);

    [Fx_ml,Fy_ml]=mysincos2(Fx_mlt,Fy_mlt,delta_ml);

    [Fx_mr,Fy_mr]=mysincos2(Fx_mrt,Fy_mrt,delta_mr);

    [Fx_fl,Fy_fl]=mysincos2(Fx_flt,Fy_flt,delta_fl);

    [Fx_fr,Fy_fr]=mysincos2(Fx_frt,Fy_frt,delta_fr);

    [Fx_rl,Fy_rl]=mysincos2(Fx_rlt,Fy_rlt,delta_rl);

    [Fx_rr,Fy_rr]=mysincos2(Fx_rrt,Fy_rrt,delta_rr);

end

function[x,y]=mysincos2(u1,u2,theta)
    x=u1.*cos(theta)-u2.*sin(theta);
    y=u1.*sin(theta)+u2.*cos(theta);
end



function F=Calc3DOF3AxleZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,Fext,Mext,Fh,Mh,h,hh,hl,a,b,c,dh)




    w1=w(1);
    w2=w(2);
    w3=w(3);

    x1=a;
    x2=-b;
    x3=-c;

    Fhx=Fh(1);
    Fhy=Fh(2);
    Fhz=Fh(3);

    Mhx=Mh(1);
    Mhy=Mh(2);

    Fextx=Fext(1);
    Fexty=Fext(2);
    Fextz=Fext(3);

    Mextx=Mext(1);
    Mexty=Mext(2);

    B1=h*m*yddot-Mhx-Fexty*h-Fhy*hh-Fhz*hl-Mextx+h*m*r*xdot;
    B2=Fextx*h-Mhy-Fhz*dh-Mexty+Fhx*hh-h*m*xddot+h*m*r*ydot-g*h*m*sin(gamma);
    B3=-Fextz-Fhz-g*m*cos(gamma);

    F=[(B2*w1*x2-4*B1*x2^2-4*B1*x3^2-2*B2*w1*x1-4*B1*x1^2-2*B2*w2*x1+B2*w1*x3+B2*w2*x2-2*B2*w3*x1+B2*w2*x3+B2*w3*x2+B2*w3*x3+4*B1*x1*x2+4*B1*x1*x3+4*B1*x2*x3-4*B3*d*x1^2-4*B3*d*x2^2-4*B3*d*x3^2+B3*w1*x2^2+B3*w1*x3^2+B3*w2*x2^2+B3*w2*x3^2+B3*w3*x2^2+B3*w3*x3^2-B3*w1*x1*x2-B3*w1*x1*x3-B3*w2*x1*x2-B3*w2*x1*x3-B3*w3*x1*x2-B3*w3*x1*x3+4*B3*d*x1*x2+4*B3*d*x1*x3+4*B3*d*x2*x3)/(4*(w1+w2+w3)*(-x1^2+x1*x2+x1*x3-x2^2+x2*x3-x3^2));
    (4*B1*x1^2+4*B1*x2^2+4*B1*x3^2-2*B2*w1*x1+B2*w1*x2-2*B2*w2*x1+B2*w1*x3+B2*w2*x2-2*B2*w3*x1+B2*w2*x3+B2*w3*x2+B2*w3*x3-4*B1*x1*x2-4*B1*x1*x3-4*B1*x2*x3+4*B3*d*x1^2+4*B3*d*x2^2+4*B3*d*x3^2+B3*w1*x2^2+B3*w1*x3^2+B3*w2*x2^2+B3*w2*x3^2+B3*w3*x2^2+B3*w3*x3^2-B3*w1*x1*x2-B3*w1*x1*x3-B3*w2*x1*x2-B3*w2*x1*x3-B3*w3*x1*x2-B3*w3*x1*x3-4*B3*d*x1*x2-4*B3*d*x1*x3-4*B3*d*x2*x3)/(4*(w1+w2+w3)*(-x1^2+x1*x2+x1*x3-x2^2+x2*x3-x3^2));
    (B2*w1*x1-4*B1*x2^2-4*B1*x3^2-4*B1*x1^2-2*B2*w1*x2+B2*w2*x1+B2*w1*x3-2*B2*w2*x2+B2*w3*x1+B2*w2*x3-2*B2*w3*x2+B2*w3*x3+4*B1*x1*x2+4*B1*x1*x3+4*B1*x2*x3-4*B3*d*x1^2-4*B3*d*x2^2-4*B3*d*x3^2+B3*w1*x1^2+B3*w2*x1^2+B3*w1*x3^2+B3*w3*x1^2+B3*w2*x3^2+B3*w3*x3^2-B3*w1*x1*x2-B3*w2*x1*x2-B3*w1*x2*x3-B3*w3*x1*x2-B3*w2*x2*x3-B3*w3*x2*x3+4*B3*d*x1*x2+4*B3*d*x1*x3+4*B3*d*x2*x3)/(4*(w1+w2+w3)*(-x1^2+x1*x2+x1*x3-x2^2+x2*x3-x3^2));
    -(4*B1*x1^2+4*B1*x2^2+4*B1*x3^2+B2*w1*x1-2*B2*w1*x2+B2*w2*x1+B2*w1*x3-2*B2*w2*x2+B2*w3*x1+B2*w2*x3-2*B2*w3*x2+B2*w3*x3-4*B1*x1*x2-4*B1*x1*x3-4*B1*x2*x3+4*B3*d*x1^2+4*B3*d*x2^2+4*B3*d*x3^2+B3*w1*x1^2+B3*w2*x1^2+B3*w1*x3^2+B3*w3*x1^2+B3*w2*x3^2+B3*w3*x3^2-B3*w1*x1*x2-B3*w2*x1*x2-B3*w1*x2*x3-B3*w3*x1*x2-B3*w2*x2*x3-B3*w3*x2*x3-4*B3*d*x1*x2-4*B3*d*x1*x3-4*B3*d*x2*x3)/(4*(w1*x1^2+w1*x2^2+w2*x1^2+w1*x3^2+w2*x2^2+w3*x1^2+w2*x3^2+w3*x2^2+w3*x3^2-w1*x1*x2-w1*x1*x3-w2*x1*x2-w1*x2*x3-w2*x1*x3-w3*x1*x2-w2*x2*x3-w3*x1*x3-w3*x2*x3));
    -(B2*w1*x1-4*B1*x2^2-4*B1*x3^2-4*B1*x1^2+B2*w1*x2+B2*w2*x1-2*B2*w1*x3+B2*w2*x2+B2*w3*x1-2*B2*w2*x3+B2*w3*x2-2*B2*w3*x3+4*B1*x1*x2+4*B1*x1*x3+4*B1*x2*x3-4*B3*d*x1^2-4*B3*d*x2^2-4*B3*d*x3^2+B3*w1*x1^2+B3*w1*x2^2+B3*w2*x1^2+B3*w2*x2^2+B3*w3*x1^2+B3*w3*x2^2-B3*w1*x1*x3-B3*w1*x2*x3-B3*w2*x1*x3-B3*w2*x2*x3-B3*w3*x1*x3-B3*w3*x2*x3+4*B3*d*x1*x2+4*B3*d*x1*x3+4*B3*d*x2*x3)/(4*(w1*x1^2+w1*x2^2+w2*x1^2+w1*x3^2+w2*x2^2+w3*x1^2+w2*x3^2+w3*x2^2+w3*x3^2-w1*x1*x2-w1*x1*x3-w2*x1*x2-w1*x2*x3-w2*x1*x3-w3*x1*x2-w2*x2*x3-w3*x1*x3-w3*x2*x3));
    -(4*B1*x1^2+4*B1*x2^2+4*B1*x3^2+B2*w1*x1+B2*w1*x2+B2*w2*x1-2*B2*w1*x3+B2*w2*x2+B2*w3*x1-2*B2*w2*x3+B2*w3*x2-2*B2*w3*x3-4*B1*x1*x2-4*B1*x1*x3-4*B1*x2*x3+4*B3*d*x1^2+4*B3*d*x2^2+4*B3*d*x3^2+B3*w1*x1^2+B3*w1*x2^2+B3*w2*x1^2+B3*w2*x2^2+B3*w3*x1^2+B3*w3*x2^2-B3*w1*x1*x3-B3*w1*x2*x3-B3*w2*x1*x3-B3*w2*x2*x3-B3*w3*x1*x3-B3*w3*x2*x3-4*B3*d*x1*x2-4*B3*d*x1*x3-4*B3*d*x2*x3)/(4*(w1*x1^2+w1*x2^2+w2*x1^2+w1*x3^2+w2*x2^2+w3*x1^2+w2*x3^2+w3*x2^2+w3*x3^2-w1*x1*x2-w1*x1*x3-w2*x1*x2-w1*x2*x3-w2*x1*x3-w3*x1*x2-w2*x2*x3-w3*x1*x3-w3*x2*x3))];

end

