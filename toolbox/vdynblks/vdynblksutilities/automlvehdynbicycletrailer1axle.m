function[yOut,FTotal,MTotal,FOut,Fhz,FTire,Fg,wheelInfo,stateDer,status]=automlvehdynbicycletrailer1axle(delta_f,mu,a,h,dh_f,dh_r,hh_f,hh_r,m,NF,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,Cy_f,stateVec)%#codegen

    coder.allowpcode('plain')











    xdot=stateVec(1);
    ydot=stateVec(2);

    r=stateVec(4);
    Vwheel_f=sqrt((ydot-a.*r).^2+xdot.^2);

    grade=0;
    gamma=pi/180*grade;

    [~,xdot_pabs]=automldiv0protect(xdot,xdot_tol);
    alfa_f=atan2((ydot-a*r),xdot_pabs)-delta_f.*tanh(4.*xdot);

    Fz=0.;

    for iterCnt=0:5
        if iterCnt==0

            [F,~]=Calc3DOF2AxleZReactionForcesTrailerBicycle(0,0,r,m,g,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,a,dh_f,dh_r);

            Fz_f=F;

            Fzinit=automlsatfunc(Fz_f,0);

        else

            Fzinit=Fz;

        end

        switch inputMode
        case 1

            Fx_f=0;
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;

            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);

        case 2

            Fx_f=F_f(1);
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;

            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);

        case 3

            Fx_f=F_f(1);
            Fy_f=F_f(2);

            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);

        otherwise
            Fx_f=0;
            Fy_f=0;
        end


        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fx_f+Fh_f(1)+Fh_r(1)-m.*g.*sin(gamma)+F_ext(1))./m;
        end
        yddot=-xdot.*r+(Fy_f+F_ext(2)+Fh_f(2)+Fh_r(2))./m;
        rdot=(-a*Fy_f+dh_f.*Fh_f(2)-dh_r.*Fh_r(2)+Mh_f(3)+Mh_r(3)+M_ext(3))./Izz;

        [F,Fhz]=Calc3DOF2AxleZReactionForcesTrailerBicycle(xddot,ydot,r,m,g,gamma,F_ext,M_ext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,a,dh_f,dh_r);

        Fz_f=F(1);

        Fz=automlsatfunc(Fz_f,0);
        Fz_f=Fz(1);

        maxFerr=max(abs(Fz-Fzinit));
    end

    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_f;Vwheel_f];
    yOut=[xddot;yddot;rdot];
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    FTire=[Fx_ft./NF;Fy_ft./NF;Fz_f./NF];
    FOut=[Fx_f;Fy_f;Fz_f];
    Fg=[0;0;m.*g];
    status=maxFerr;

end


function[F,Fhz_f]=Calc3DOF2AxleZReactionForcesTrailerBicycle(xddot,ydot,r,m,g,gamma,Fext,Mext,Fh_f,Mh_f,Fh_r,Mh_r,h,hh_f,hh_r,a,dh_f,dh_r)

    x1=-a;

    Fhx_f=Fh_f(1);

    Fhx_r=Fh_r(1);
    Fhz_r=Fh_r(3);

    Mhy_f=Mh_f(2);

    Mhy_r=Mh_r(2);

    Fextx=Fext(1);
    Fextz=Fext(3);

    Mexty=Mext(2);

    B1=Fextx*h-Mhy_f-Mhy_r-Fhz_r*dh_r-Mexty+Fhx_f*hh_f+Fhx_r*hh_r-h*m*xddot+h*m*r*ydot-g*h*m*sin(gamma);
    B2=Fextz+Fhz_r+g*m*cos(gamma);

    F=-(B1-B2*dh_f)/(dh_f-x1);

    Fhz_f=-(B1-B2*x1)/(dh_f-x1);

    if Fh_f(3)~=0

        Fhz_f=Fhz_f+Fh_f(3);

        F=Fextz+Fhz_f+Fhz_r+g*m*cos(gamma);

    end

end