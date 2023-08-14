function[yOut,FTotal,MTotal,FOut,FTire,Fg,wheelInfo,stateDer,status]=automlvehdynbicycle(delta_f,delta_r,mu,a,b,h,m,Nf,Nr,Izz,g,Fxtire_sat,Fytire_sat,inputMode,xdot_tol,Fznom,F_f,F_r,F_ext,M_ext,Fh,Mh,Cy_f,Cy_r,dh,hh,stateVec)%#codegen
    coder.allowpcode('plain')










    xdot=stateVec(1);
    ydot=stateVec(2);

    r=stateVec(4);
    Vwheel_f=sqrt((ydot+a.*r).^2+xdot.^2);
    Vwheel_r=sqrt((ydot-b.*r).^2+xdot.^2);

    grade=0;
    gamma=pi/180*grade;
    [~,xdot_pabs]=automldiv0protect(xdot,xdot_tol);
    alfa_f=atan2((ydot+a*r),xdot_pabs)-delta_f.*tanh(4.*xdot);
    alfa_r=atan2((ydot-b*r),xdot_pabs)-delta_r.*tanh(4.*xdot);
    Fz=zeros(1,2);

    for iterCnt=0:5
        if iterCnt==0
            FzCalc=Calc3DOF2AxleZReactionForcesBicycle(0,0,r,m,g,gamma,F_ext,M_ext,Fh,Mh,h,hh,a,b,dh);
            Fzinit=automlsatfunc(FzCalc,0);
        else
            Fzinit=Fz;
        end
        switch inputMode
        case 1
            Fx_f=0;
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;
            Fx_r=0;
            Fy_r=-Cy_r.*alfa_r.*mu(2).*Fzinit(2)./Fznom;
            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);
            Fx_r=Fx_rt.*cos(delta_r)-Fy_rt.*sin(delta_r);
            Fy_r=-Fx_r.*sin(delta_r)+Fy_r.*cos(delta_r);
        case 2
            Fx_f=F_f(1);
            Fy_f=-Cy_f.*alfa_f.*mu(1).*Fzinit(1)./Fznom;
            Fx_r=F_r(1);
            Fy_r=-Cy_r.*alfa_r.*mu(2).*Fzinit(2)./Fznom;
            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);

            Fx_f=Fx_ft.*cos(delta_f)-Fy_ft.*sin(delta_f);
            Fy_f=-Fx_f.*sin(delta_f)+Fy_f.*cos(delta_f);
            Fx_r=Fx_rt.*cos(delta_r)-Fy_rt.*sin(delta_r);
            Fy_r=-Fx_r.*sin(delta_r)+Fy_r.*cos(delta_r);
        case 3
            Fx_f=F_f(1);
            Fy_f=F_f(2);
            Fx_r=F_r(1);
            Fy_r=F_r(2);
            [Fx_ft,Fy_ft]=automlvehdynftiresat(Fx_f,Fy_f,Fxtire_sat.*Fzinit(1)./Fznom,Fytire_sat.*Fzinit(1)./Fznom,1);
            [Fx_rt,Fy_rt]=automlvehdynftiresat(Fx_r,Fy_r,Fxtire_sat.*Fzinit(2)./Fznom,Fytire_sat.*Fzinit(2)./Fznom,1);
        otherwise
            Fx_f=0;
            Fy_f=0;
            Fx_r=0;
            Fy_r=0;
        end

        if inputMode==1
            xddot=0;
        else
            xddot=ydot.*r+(Fx_f+Fx_r-m.*g.*sin(gamma)+F_ext(1)+Fh(1))./m;
        end

        yddot=-xdot.*r+(Fy_f+Fy_r+F_ext(2)+Fh(2))./m;
        rdot=(a.*Fy_f-b.*Fy_r+M_ext(3)+Mh(3)-Fh(2)*dh)./Izz;

        FzCalc=Calc3DOF2AxleZReactionForcesBicycle(xddot,ydot,r,m,g,gamma,F_ext,M_ext,Fh,Mh,h,hh,a,b,dh);
        Fz=automlsatfunc(FzCalc,0);
        Fz_f=Fz(1);
        Fz_r=Fz(2);

        maxFerr=max(abs(Fz-Fzinit));
    end
    stateDer=[xddot;yddot;r;rdot];

    wheelInfo=[alfa_f;Vwheel_f;alfa_r;Vwheel_r];
    yOut=[xddot;yddot;rdot];
    FTotal=[(xddot-ydot.*r).*m;(yddot+xdot.*r).*m;0];
    MTotal=[0;rdot.*Izz;0];
    FTire=[Fx_ft./Nf;Fy_ft./Nf;Fz_f./Nf;Fx_rt./Nr;Fy_rt./Nr;Fz_r./Nr];
    FOut=[Fx_f;Fy_f;Fz_f;Fx_r;Fy_r;Fz_r];
    Fg=[0;0;m.*g];
    status=maxFerr;
end

function Fz=Calc3DOF2AxleZReactionForcesBicycle(xddot,ydot,r,m,g,gamma,Fext,Mext,Fh,Mh,h,hh,a,b,dh)



    Fz=[0,0];

    B1=h*(Fext(1)+Fh(1)-m*(xddot-r*ydot)-m*g*sin(gamma))-Mh(2)-Fh(3)*dh-Fh(1)*(h-hh)-Mext(2);
    B2=-Fext(3)-Fh(3)-m*g*cos(gamma);

    Fz(1,1)=-(B1-B2*b)/(a+b);

    Fz(1,2)=(B1+B2*a)/(a+b);


    Fz=-Fz;

end