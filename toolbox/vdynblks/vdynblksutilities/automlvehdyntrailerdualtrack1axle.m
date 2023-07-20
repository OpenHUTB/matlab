function[yOut,FTotal,MTotal,FOut,Fhz,FTire,Fg,wheelInfo,stateDer,status]=automlvehdyntrailerdualtrack1axle(delta_f,mu,a,d,dh_f,dh_r,hl_f,hl_r,h,hh_f,hh_r,w,m,NF,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,Cy_f,stateVec)
%#codegen
    coder.allowpcode('plain')











    xdot=stateVec(1);
    ydot=stateVec(2);
    r=stateVec(4);

    Xwheel_fl=sqrt(a.^2+(w(1)./2).^2);

    Vwheel_fl=sqrt((ydot-Xwheel_fl.*r).^2+xdot.^2);
    Vwheel_fr=Vwheel_fl;

    grade=0;
    gamma=pi/180.*grade;
    [xdot_p,~]=automldiv0protect(xdot,xdot_tol);
    delta_fl=delta_f(1);
    delta_fr=delta_f(2);

    alfa_fl=atan2((ydot-a*r),abs(xdot_p+w(1)./2.*r))-delta_fl.*tanh(4.*xdot);
    alfa_fr=atan2((ydot-a*r),abs(xdot_p-w(1)./2.*r))-delta_fr.*tanh(4.*xdot);

    Fz=zeros(1,2);

    for iterCnt=0:10

        if iterCnt==0

            [F,~]=Calc3DOF2AxleTrailerZReactionForces(0,xdot,0,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,dh_f,dh_r);

            Fz_fl=F(1);
            Fz_fr=F(2);

            Fzinit=automlsatfunc([Fz_fl,Fz_fr],0);
        else
            Fzinit=Fz;
        end

        switch inputMode
        case 1

            Fx_fl=0;
            Fx_fr=0;

            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;

            [Fx_fl,Fy_fl,Fx_fr,Fy_fr]=tire2bodyF(delta_fl,delta_fr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);

        case 2

            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);

            Fy_fl=-Cy_f(1)./2.*alfa_fl.*mu(1,1).*Fzinit(1)./Fznom;
            Fy_fr=-Cy_f(2)./2.*alfa_fr.*mu(1,2).*Fzinit(2)./Fznom;

            [Fx_fl,Fy_fl,Fx_fr,Fy_fr]=tire2bodyF(delta_fl,delta_fr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fxtire_sat.*Fzinit./Fznom,Fytire_sat.*Fzinit./Fznom);

        case 3

            Fx_fl=F_f(1,1);
            Fx_fr=F_f(2,1);
            Fy_fl=F_f(1,2);
            Fy_fr=F_f(2,2);

        otherwise

            Fx_fl=0;
            Fx_fr=0;
            Fy_fl=0;
            Fy_fr=0;
        end

        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fx_fl+Fx_fr+Fh_f(1)+Fh_r(1)-m*g.*sin(gamma)+F_ext(1))./m;
        end

        yddot=-xdot.*r+(Fy_fl+Fy_fr+F_ext(2)+Fh_f(2)+Fh_r(2))./m;

        rdot=(-a.*(Fy_fl+Fy_fr)+dh_f.*Fh_f(2)-dh_r.*Fh_r(2)+w(1)./2.*(Fx_fl-Fx_fr)...
        +M_ext(3)+Mh_f(3)+Mh_r(3)-Fh_f(1)*(hl_f-d)-Fh_r(1)*(hl_r-d))./Izz;

        [F,Fhz]=Calc3DOF2AxleTrailerZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,dh_f,dh_r);

        Fz_fl=F(1);
        Fz_fr=F(2);

        Fz=automlsatfunc([Fz_fl,Fz_fr],0);
        maxFerr=max(abs(Fz-Fzinit));

    end

    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_fl;alfa_fr;Vwheel_fl;Vwheel_fr];
    yOut=[xddot;yddot;rdot];
    FOut=[Fx_fl;Fy_fl;Fz(1);Fx_fr;Fy_fr;Fz(2)];
    FTire=[Fx_fl.*2./NF;Fy_fl.*2./NF;Fz(1).*2./NF;Fx_fr.*2./NF;Fy_fr.*2./NF;Fz(2).*2./NF];
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    Fg=[0;0;m.*g];
    status=maxFerr;

end


function[Fx_fl,Fy_fl,Fx_fr,Fy_fr]=tire2bodyF(delta_fl,delta_fr,Fx_fl,Fy_fl,Fx_fr,Fy_fr,Fxtire_sat,Fytire_sat)

    [Fx_flt,Fy_flt]=automlvehdynftiresat(Fx_fl,Fy_fl,Fxtire_sat(1),Fytire_sat(1),1);
    [Fx_frt,Fy_frt]=automlvehdynftiresat(Fx_fr,Fy_fr,Fxtire_sat(2),Fytire_sat(2),1);

    [Fx_fl,Fy_fl]=mysincos2(Fx_flt,Fy_flt,delta_fl);

    [Fx_fr,Fy_fr]=mysincos2(Fx_frt,Fy_frt,delta_fr);
end

function[x,y]=mysincos2(u1,u2,theta)
    x=u1.*cos(theta)-u2.*sin(theta);
    y=u1.*sin(theta)+u2.*cos(theta);
end



function[F,Fhz_f]=Calc3DOF2AxleTrailerZReactionForces(xddot,xdot,yddot,ydot,r,m,g,w,d,gamma,Fext,Mext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,hl_f,hl_r,a,dh_f,dh_r)

    w1=w(1);

    x1=-a;

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

    F=[(2*B2*d+2*B1*dh_f+2*B2*hl_f-B2*w1-2*B1*x1-2*B3*d*dh_f+B3*dh_f*w1-2*B3*hl_f*x1)/(2*w1*(dh_f-x1));
    -(2*B2*d+2*B1*dh_f+2*B2*hl_f+B2*w1-2*B1*x1-2*B3*d*dh_f-B3*dh_f*w1-2*B3*hl_f*x1)/(2*w1*(dh_f-x1))];

    Fhz_f=-(B2-B3*x1)/(dh_f-x1);

    if Fh_f(3)~=0

        Fhz_f=Fhz_f+Fh_f(3);

        B1=h*m*yddot-Mhx_f-Mhx_r-Fexty*h-Fhy_f*hh_f-Fhy_r*hh_r-Fhz_f*hl_f-Fhz_r*hl_r-Mextx+h*m*r*xdot;
        B2=Fextz+Fhz_f+Fhz_r+g*m*cos(gamma);

        F=[(2*B1-2*B2*d+B2*w1)/(2*w1);...
        (2*B2*d-2*B1+B2*w1)/(2*w1)];

    end

end