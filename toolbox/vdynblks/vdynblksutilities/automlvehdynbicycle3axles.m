function[yOut,FTotal,MTotal,FOut,FTire,Fg,wheelInfo,stateDer,status]=automlvehdynbicycle3axles(delta_f,delta_m,delta_r,mu,a,b,c,h,dh,hh,m,NF,NM,NR,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_m,F_r,F_ext,M_ext,Fh,Mh,Cy_f,Cy_m,Cy_r,stateVec)%#codegen
    coder.allowpcode('plain')











    xdot=stateVec(1);
    ydot=stateVec(2);

    r=stateVec(4);
    Vwheel_f=sqrt((ydot+a.*r).^2+xdot.^2);
    Vwheel_m=sqrt((ydot-b.*r).^2+xdot.^2);
    Vwheel_r=sqrt((ydot-c.*r).^2+xdot.^2);

    grade=0;
    gamma=pi/180*grade;

    [~,xdot_pabs]=automldiv0protect(xdot,xdot_tol);
    alfa_f=atan2((ydot+a*r),xdot_pabs)-delta_f.*tanh(4.*xdot);
    alfa_m=atan2((ydot-b*r),xdot_pabs)-delta_m.*tanh(4.*xdot);
    alfa_r=atan2((ydot-c*r),xdot_pabs)-delta_r.*tanh(4.*xdot);


    Fz=zeros(1,3);


    for iterCnt=0:5
        if iterCnt==0

            F=Calc3DOF3AxleZReactionForcesBicycle(0,0,r,m,g,gamma,F_ext,M_ext,Fh,Mh,h,hh,a,b,c,dh);

            Fz_f=F(1);
            Fz_m=F(2);
            Fz_r=F(3);

            Fzinit=automlsatfunc([Fz_f,Fz_m,Fz_r],0);

        else

            Fzinit=Fz;

        end

        switch inputMode
        case 1

            Fx_f=0;
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;
            Fx_m=0;
            Fy_m=-Cy_m.*alfa_m.*mu(2).*Fzinit(2)./Fznom;
            Fx_r=0;
            Fy_r=-Cy_r.*alfa_r.*mu(3).*Fzinit(3)./Fznom;

            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_mt,Fy_mt]=automlvehdynftiresat(Fx_m,Fy_m,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(3)./Fznom,Fytire_sat.*Fzinit(3)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);
            Fx_m=Fx_mt.*cos(delta_m)-Fy_mt.*sin(delta_m);
            Fy_m=-Fx_m.*sin(delta_m)+Fy_m.*cos(delta_m);
            Fx_r=Fx_rt.*cos(delta_r)-Fy_rt.*sin(delta_r);
            Fy_r=-Fx_r.*sin(delta_r)+Fy_r.*cos(delta_r);

        case 2

            Fx_f=F_f(1);
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;
            Fx_m=F_m(1);
            Fy_m=-Cy_m.*alfa_m.*mu(2).*Fzinit(2)./Fznom;
            Fx_r=F_r(1);
            Fy_r=-Cy_r.*alfa_r.*mu(3).*Fzinit(3)./Fznom;
            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_mt,Fy_mt]=automlvehdynftiresat(Fx_m,Fy_m,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(3)./Fznom,Fytire_sat.*Fzinit(3)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);
            Fx_m=Fx_mt.*cos(delta_m)-Fy_mt.*sin(delta_m);
            Fy_m=-Fx_m.*sin(delta_m)+Fy_m.*cos(delta_m);
            Fx_r=Fx_rt.*cos(delta_r)-Fy_rt.*sin(delta_r);
            Fy_r=-Fx_r.*sin(delta_r)+Fy_r.*cos(delta_r);

        case 3

            Fx_f=F_f(1);
            Fy_f=F_f(2);
            Fx_m=F_m(1);
            Fy_m=F_m(2);
            Fx_r=F_r(1);
            Fy_r=F_r(2);
            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_mt,Fy_mt]=automlvehdynftiresat(Fx_m,Fy_m,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(3)./Fznom,Fytire_sat.*Fzinit(3)./Fznom,1);

        otherwise
            Fx_f=0;
            Fy_f=0;
            Fx_m=0;
            Fy_m=0;
            Fx_r=0;
            Fy_r=0;
        end


        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fh(1)+Fx_f+Fx_m+Fx_r-m.*g.*sin(gamma)+F_ext(1))./m;
        end
        yddot=-xdot.*r+(Fy_f+Fy_m+Fy_r+F_ext(2)+Fh(2))./m;
        rdot=(a.*Fy_f-b.*Fy_m-c.*Fy_r-dh.*Fh(2)+M_ext(3)+Mh(3))./Izz;

        F=Calc3DOF3AxleZReactionForcesBicycle(xddot,ydot,r,m,g,gamma,F_ext,M_ext,Fh,Mh,h,hh,a,b,c,dh);

        Fz_f=F(1);
        Fz_m=F(2);
        Fz_r=F(3);

        Fz=automlsatfunc([Fz_f,Fz_m,Fz_r],0);
        Fz_f=Fz(1);
        Fz_m=Fz(2);
        Fz_r=Fz(3);

        maxFerr=max(abs(Fz-Fzinit));
    end
    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_f;Vwheel_f;alfa_m;Vwheel_m;alfa_r;Vwheel_r];
    yOut=[xddot;yddot;rdot];
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    FTire=[Fx_ft./NF;Fy_ft./NF;Fz_f./NF;Fx_mt./NM;Fy_mt./NM;Fz_m./NM;Fx_rt./NR;Fy_rt./NR;Fz_r./NR];
    FOut=[Fx_f;Fy_f;Fz_f;Fx_m;Fy_m;Fz_m;Fx_r;Fy_r;Fz_r];
    Fg=[0;0;m.*g];
    status=maxFerr;

end


function F=Calc3DOF3AxleZReactionForcesBicycle(xddot,ydot,r,m,g,gamma,Fext,Mext,Fh,Mh,h,hh,a,b,c,dh)



    x1=a;

    x2=-b;

    x3=-c;

    Fhx=Fh(1);

    Fhz=Fh(3);

    Mhy=Mh(2);

    Fextx=Fext(1);

    Fextz=Fext(3);

    Mexty=Mext(2);

    B1=Fextx*h-Mhy-Fhz*dh-Mexty+Fhx*hh-h*m*xddot+h*m*r*ydot-g*h*m*sin(gamma);
    B2=-Fextz-Fhz-g*m*cos(gamma);

    denom=2*(-x1^2+x1*x2+x1*x3-x2^2+x2*x3-x3^2);

    F=[(B1*x2-2*B1*x1+B1*x3+B2*x2^2+B2*x3^2-B2*x1*x2-B2*x1*x3)/denom;
    (B1*x1-2*B1*x2+B1*x3+B2*x1^2+B2*x3^2-B2*x1*x2-B2*x2*x3)/denom;
    (B1*x1+B1*x2-2*B1*x3+B2*x1^2+B2*x2^2-B2*x1*x3-B2*x2*x3)/denom];

end