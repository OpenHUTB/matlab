function[Qinit,SC,params,Ts,WantBlockChoice]=supercapacitorParam(C,Rdc,Voltage,Ns,Np,Vinit,Temp,Nc,r,epsilon,Ich,Vstern,Ioc,Vself,block)










    SC.X=[-70,20];
    SC.bas=-60;
    SC.haut=40;
    SC.dim_Xsin=SC.X(1):1:SC.X(2);
    SC.dim_sin=0:pi/2/((-SC.X(1)+SC.X(2))/2):2*pi/2;
    SC.TopX=[-30,-10];
    SC.TopX=[-30,-10];
    SC.dim_Xtop=SC.TopX(1):1:SC.TopX(2);
    SC.dim_top=0:pi/2/((-SC.TopX(1)+SC.TopX(2))/2):2*pi/2;

    [X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,SC.color1,SC.color2]=spsdrivelogo;

    scale=180;
    SC.dx=0.6;
    SC.dy=0.65;
    SC.X1=(X1-SC.dx)*scale;
    SC.X1m=(X1m-SC.dx)*scale;
    SC.X2=(X2-SC.dx)*scale;
    SC.X2m=(X2m-SC.dx)*scale;
    SC.X3=(X3-SC.dx)*scale;
    SC.X4=(X4-SC.dx)*scale;
    SC.Y1=(Y1-SC.dy)*scale;
    SC.Y1m=(Y1m-SC.dy)*scale;
    SC.Y2=(Y2-SC.dy)*scale;
    SC.Y2m=(Y2m-SC.dy)*scale;
    SC.Y3=(Y3-SC.dy)*scale;
    SC.Y4=(Y4-SC.dy)*scale;



    PowerguiInfo=powericon('getPowerguiInfo',bdroot(block),block);
    Ts=PowerguiInfo.Ts;
    if PowerguiInfo.Discrete
        WantBlockChoice='Discrete';
    else
        WantBlockChoice='Continuous';
    end

    StoppedSimulation=isequal('stopped',get_param(bdroot(block),'SimulationStatus'));

    if strcmp(get_param(block,'PresetModel'),'on')&&StoppedSimulation

        set_param(block,'Nc','1')
        Nc=1;

        set_param(block,'r','1e-9')
        r=1e-9;

        set_param(block,'epsilon','6.0208e-10')
        epsilon=6.0208e-10;
    end

    T=273.15+Temp;
    R=8.314472;
    F=96485.3383;
    L=6.02214199e23;

    epsilon0=8.854187e-12;
    epsilonR=68;
    epsilona=epsilon0*epsilonR;

    ra=1e-9;
    Ne=1;
    c=(1/(8*L*ra^3));

    Q=C*Voltage;
    invC_stern=Ns*ra/(Np*Ne*epsilona)+(2*Ns*Ne*R*T)/(F*Np*Q)*asinh(Q/(Ne^2*sqrt(8*R*T*epsilona*c)));
    C_stern=1/invC_stern;
    Ai=C/C_stern;
    V=[Vstern(1:3),Voltage];
    Ich=-Ich;


    if strcmp(get_param(block,'EstParam'),'on')&&~isempty(ver('optim'))&&license('test','Optimization_Toolbox')

        Tol=1e-1;
        maxNbIter=100;
        stopIfFound=true;


        alpha0=Ns*ra/(Np*Ne*epsilona*Ai);
        beta0=(2*Ne*R*T*Ns)/(F*Np);
        lamda0=1/(Ne^2*Ai*sqrt(8*R*T*epsilona*c));
        X0=[alpha0,beta0,lamda0];


        SolFound=false;
        minMaxError=1;
        bestParams=zeros(1,3);

        for k=1:maxNbIter

            lb=X0/1000;
            ub=X0*1000;
            x0=X0;

            f=@(x)optim(x,V,C,Rdc,Ich);
            options=optimset('LargeScale','on','Display','off','MaxFunEvals',1000,'MaxIter',100);

            [x,~,Residual,exitflag]=lsqnonlin(f,x0,lb,ub,options);

            Res=abs(Residual);
            alpha=x(1);
            beta=x(2);
            lamda=x(3);
            maxRes=max(Res);

            if((exitflag>0)&&(maxRes<Tol))
                MaxError=maxRes;
                SolFound=true;
                if stopIfFound==1
                    break
                else
                    if maxRes<minMaxError
                        minMaxError=maxRes;
                        bestParams=[alpha,beta,lamda];
                    end
                end
            else
                if maxRes<minMaxError
                    minMaxError=maxRes;
                    bestParams=[alpha,beta,lamda];
                end
            end
        end




        params.solutionFound=SolFound;

        if SolFound&&stopIfFound==1
            params.alpha=alpha;
            params.beta=beta;
            params.lamda=lamda;
            params.maxError=MaxError;
        else
            params.alpha=bestParams(1);
            params.beta=bestParams(2);
            params.lamda=bestParams(3);
            params.maxError=minMaxError;
        end

        if StoppedSimulation


            alpha1=Np*params.alpha/Ns;
            beta1=Np*params.beta/(T*Ns);
            lamda1=params.lamda*sqrt(T);
            Nc_est=max(round(F*beta1/(2*R)),1);
            r_est=lamda1*sqrt(R*Ai*Nc_est^3/(alpha1*L));
            epsilon_est=r_est/(alpha1*Nc_est*Ai);

            set_param(block,'Nc',num2str(Nc_est))
            set_param(block,'r',num2str(r_est))
            set_param(block,'epsilon',num2str(epsilon_est))

        end

    else
        c=(1/(8*L*r^3));
        params.alpha=Ns*r/(Np*Nc*epsilon*Ai);
        params.beta=(2*Ns*Nc*R*T)/(F*Np);
        params.lamda=1/(Nc^2*Ai*sqrt(8*R*T*epsilon*c));
        params.maxError=[];
    end


    if strcmp(get_param(block,'Self_dis'),'on')
        a1=((Vself(1)-Ioc*Rdc)-Vself(2))/10;
        a2=(Vself(2)-Vself(3))/90;
        a3=(Vself(3)-Vself(4))/900;
    else
        a1=0;
        a2=0;
        a3=0;
    end

    params.a1=a1;
    params.a2=a2;
    params.a3=a3;
    params.Ai=Ai;



    Qinit=0;
    Qi=0:10e-3:C*Vinit;
    Vcap=params.alpha*Qi+params.beta*asinh(params.lamda*Qi);

    for i=1:length(Qi)
        if(abs(Vinit-Vcap(i))<10e-3)
            Qinit=Qi(i);
        end
    end



    if strcmp(get_param(block,'demandeplot'),'on')

        set_param(block,'demandeplot','off');
        Units=get_param(block,'Units');

        if strcmp(Units,'sec')
            scale_x=1;
            label='Time(sec)';

        else
            if strcmp(Units,'min')
                scale_x=1/60;
                label='Time (min)';
            else
                scale_x=1/3600;
                label='Time (hour)';
            end
        end

        hfig=findobj('Name','Supercapacitor Charge Characteristic');

        if isempty(hfig)
            figure('Name','Supercapacitor Charge Characteristic');
        end

        I=str2num(get_param(block,'I'));

        for idx=1:length(I)
            i=I(idx);
            legend_str{idx}=[num2str(i),' A'];
            if strcmp(Units,'sec')
                scale_x(idx)=1;
                label='Time (sec)';
            else
                if strcmp(Units,'min')
                    scale_x(idx)=1/60;
                    label='Time (min)';
                else
                    scale_x(idx)=1/3600;
                    label='Time (hour)';
                end
            end
            tr(idx)=C*(Voltage-Rdc*i)/i;
            t(idx,:)=0:tr(idx)/100:tr(idx);

            VT(idx,:)=params.alpha*(abs(i).*t(idx,:))+params.beta*asinh(params.lamda*(abs(i).*t(idx,:)))-Rdc*(-i);
            plot(t(idx,:)'*scale_x(idx),VT(idx,:)');

            hold all
        end

        legend(legend_str);

        title('Supercapacitor Charge Characteristic');
        xlabel(label);
        ylabel('Voltage');
        grid on
        hold off

    end

    function F=optim(x,V,C,Rdc,Ich)

        alpha=x(1);
        beta=x(2);
        lamda=x(3);
        V1=V(1);V2=V(2);V3=V(3);V4=V(4);

        tr=C*(V(4)-V(1))/abs(Ich);

        V2_est=alpha*(abs(Ich)*20+C*V1)+beta*asinh(lamda*(abs(Ich)*20+C*V1))-Rdc*Ich;
        V3_est=alpha*(abs(Ich)*60+C*V1)+beta*asinh(lamda*(abs(Ich)*60+C*V1))-Rdc*Ich;
        V4_est=alpha*(abs(Ich)*tr+C*V1)+beta*asinh(lamda*(abs(Ich)*tr+C*V1))-Rdc*Ich;

        F=[(V2_est-V2)/V2,(V3_est-V3)/V3,(V4_est-V4)/V4];