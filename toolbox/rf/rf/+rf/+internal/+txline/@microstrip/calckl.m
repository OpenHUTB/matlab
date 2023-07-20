function[y,z0_f,Eeff_f]=calckl(h,varargin)






    if nargin==2
        freq=varargin{:};
    end


    c0=rf.physconst('LightSpeed');
    mu0=pi*4e-7;
    e0=1/mu0/c0^2;
    Er=h.EpsilonR;
    zf=sqrt(mu0/e0);


    len=h.LineLength;
    width=h.Width;
    height=h.TotalHeight;
    thickness=h.Thickness;
    sigmacond=h.SigmaCond;
    losstan=h.LossTangent;



    we=calc_we(width,height,thickness);


    TempC=(Er-1)*thickness/height/4.6/sqrt(width/height);
    if width/height<=1

        TempA=(1+12*height/width)^(-1/2)+0.04*(1-width/height)^2;

        Eeff=(Er+1)/2+(Er-1)/2*TempA-TempC;


        TempA=log(8*height/we+0.25*we/height);
        z0=zf/2/pi/sqrt(Eeff)*TempA;
    else

        Eeff=(Er+1)/2+(Er-1)/2*(1+12*height/width)^(-1/2)-TempC;


        TempA=we/height+1.393+2/3*log(we/height+1.444);
        z0=zf/sqrt(Eeff)/TempA;
    end

    if nargin==2


        TempA=Er*sqrt((Eeff-1)/(Er-Eeff));
        fk_TM0=c0*atan(TempA)/(2*pi*height*sqrt(Er-Eeff));

        TempA=0.75+(0.75-(0.332/Er^1.73))*width/height;
        f50=fk_TM0/TempA;

        m0=1+1/(1+sqrt(width/height))+0.32*(1/(1+sqrt(width/height)))^3;
        mc=calc_mc(width,height,f50,freq);
        m=m0*mc;

        Eeff_f=Er-(Er-Eeff)./(1+(freq./f50).^m);

        z0_f=z0*(Eeff_f-1)./(Eeff-1).*sqrt(Eeff./Eeff_f);
        if~strcmp(h.Type,'Standard')
            [Eeff_f,z0_f]=epsilonTypeEffect(h,Eeff_f,z0_f,we);
        end
    else
        if~strcmp(h.Type,'Standard')
            [Eeff_f,z0_f]=epsilonTypeEffect(h,Eeff,z0,we);
        else
            Eeff_f=Eeff;
            z0_f=z0;
        end
        y=[];
        return
    end

    pv=c0./sqrt(Eeff_f);


    w=2*pi*freq;

    beta=w./pv;

    if thickness>eps


        Rs=sqrt(pi*freq*mu0./sigmacond);


        height=h.Height;
        TempB=calc_B(width,height);

        TempA=1+height/we*(1+1.25/pi*log(2*TempB/thickness));
        if width/height<=1
            TempC=(32-(we/height)^2)/(32+(we/height)^2);
            alpha_c=1.38*TempC/height/z0*TempA.*Rs;
        else
            TempC=we/height+2/3*we/height/(we/height+1.444);

            alpha_c=6.1e-5*TempA*z0*TempC.*Rs.*Eeff_f./height;
        end
    else
        alpha_c=0;
    end


    lamda0=c0./freq;
    alpha_d=27.3*Er/(Er-1)*(Eeff_f-1).*losstan./sqrt(Eeff_f)./lamda0;

    alphadB=alpha_c+alpha_d;
    alphadB(alphadB==inf)=1/eps;

    e_alpha=(10.^(-alphadB./20)).^len;


    h.PV=pv;
    h.Loss=alphadB;

    y=e_alpha.*exp(-1j*beta*len);
end

function we=calc_we(w,h,t)


    if t==0
        we=w;
    elseif w/h<=1/2/pi
        we=w+1.25*t/pi*(1+log(4*pi*w/t));
    else
        we=w+1.25*t/pi*(1+log(2*h/t));
    end
end


function mc=calc_mc(w,h,f50,f)

    if w/h<=0.7
        TempA=0.15-0.235*exp(-0.45*f./f50);
        mc=1+1.4/(1+w/h)*TempA;
    else
        mc=1;
    end
end

function B=calc_B(w,h)

    if w/h<=1/2/pi
        B=2*pi*w;
    else
        B=h;
    end
end