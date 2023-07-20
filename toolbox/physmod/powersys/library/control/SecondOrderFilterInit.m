function[WantBlockChoice,Ts,sps]=SecondOrderFilterInit(varargin)





    if size(varargin,2)>5
        [block,FilterType,Fo,Zeta,Initialize,Vac_Init,Vdc_Init,Ts]=varargin{1:end};
    elseif size(varargin,2)==5
        [FilterType,Fo,Zeta,PlotResponse,FreqRange]=varargin{1:end};
        SecondOrderFilterPlot(FilterType,Fo,Zeta,PlotResponse,FreqRange);
        return;
    else
        block=varargin{1:end};
        SecondOrderFilterCback(block);
        return;
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);


    ParameterError=0;
    nfilt=length(Fo);
    nInput=size(Vac_Init,1);

    sps.A=[];
    sps.B=[];
    sps.C=[];
    sps.D=eye(nfilt,nfilt);
    sps.x0=0;

    if Init

        Erreur.identifier='SpecializedPowerSystems:SecondOrderFilterBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Fo<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The Cut-off frequencies must be >0.',BK);
            psberror(Erreur);
            ParameterError=1;
        end

        if length(Fo)~=length(Zeta)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the "Cut-off frequency" and "Damping factor" vectors must be the same.',BK);
            psberror(Erreur);
            ParameterError=1;
        end

        if Initialize&&size(Vac_Init,2)~=3
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of columns of the "AC initial input" matrix must be 3.',BK);
            psberror(Erreur);
            ParameterError=1;
        end

        if Initialize&&~(length(Fo)==size(Vac_Init,1)||length(Fo)==1||size(Vac_Init,1)==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of lines of the "AC initial input" matrix must be 1 or equal to the length of the "Cut-off frequency" and "Damping factor" vectors.',BK);
            psberror(Erreur);
            ParameterError=1;
        end

        if Initialize&&~(length(Fo)==length(Vdc_Init)||length(Fo)==1||length(Vdc_Init)==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the "DC initial input" vector must be 1 or equal to the length of the "Cut-off frequency" and "Damping factor" vectors.',BK);
            psberror(Erreur);
            ParameterError=1;
        end

        if Initialize&&~(size(Vac_Init,1)==length(Vdc_Init))
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of lines of the "AC initial input" matrix and the length of the "DC initial input" vector must correspond to the size of the input signal.',BK);
            psberror(Erreur);
            ParameterError=1;
        end
    end



    sps.strFreq=sprintf(' Fo=%iHz\n\n',Fo(1));
    if nfilt>1
        sps.strFreq=sprintf('Fo%d=%iHz\n...\nFo%d=%iHz\n',1,Fo(1),nfilt,Fo(end));
    end

    Wo=2*pi*Fo;

    switch WantBlockChoice
    case 'Discrete'

        for k=1:length(Fo)
            if Fo(k)<1/(2*Ts)
                Wo(k)=2/Ts*tan(Wo(k)*Ts/2);
            end
        end

    end

    switch FilterType
    case 1,
        sps.X=[0,1,2,3,4];
        sps.Y=[-1,-1,-2.5,-4,-4];
        n2=zeros(1,nfilt);n1=zeros(1,nfilt);n0=Wo.^2;
        d2=ones(1,nfilt);d1=2*Zeta.*Wo;d0=Wo.^2;

    case 2,
        sps.X=[0,1,2,3,4];
        sps.Y=[-4,-4,-2.5,-1,-1];
        n2=ones(1,nfilt);n1=zeros(1,nfilt);n0=zeros(1,nfilt);
        d2=ones(1,nfilt);d1=2*Zeta.*Wo;d0=Wo.^2;

    case 3,
        sps.X=[0,1,2,3,4,5];
        sps.Y=[-3,-3,-1,-1,-3,-3];
        n2=zeros(1,nfilt);n1=2*Zeta.*Wo;n0=zeros(1,nfilt);
        d2=ones(1,nfilt);d1=2*Zeta.*Wo;d0=Wo.^2;

    case 4,
        sps.X=[0,1,2,3,4,5];
        sps.Y=[-1,-1,-3,-3,-1,-1];
        n2=ones(1,nfilt);n1=zeros(1,nfilt);n0=Wo.^2;
        d2=ones(1,nfilt);d1=2*Zeta.*Wo;d0=Wo.^2;

    end

    if ParameterError,
        return;
    elseif Init



        Ac=[];Bc=[];Cc=[];Dc=[];

        for ifilt=1:nfilt



            a=[0,1;-d0(ifilt),-d1(ifilt)];
            b=[0;1];
            c=[(n0(ifilt)-n2(ifilt)*d0(ifilt)),(n1(ifilt)-n2(ifilt)*d1(ifilt))];
            d=n2(ifilt);

            iline=2*ifilt-1;icol=2*ifilt-1;
            Ac(iline:iline+1,icol:icol+1)=a;

            icol=ifilt;
            Bc(iline:iline+1,icol)=b;

            iline=ifilt;icol=2*ifilt-1;
            Cc(iline,icol:icol+1)=c;

            icol=ifilt;
            Dc(iline,icol)=d;
        end

        sps.A=Ac;
        sps.B=Bc;
        sps.C=Cc;
        sps.D=Dc;


        switch WantBlockChoice
        case 'Discrete'
            [Ad,Bd,Cd,Dd]=powericon('psb_c2d',Ac,Bc,Cc,Dc,Ts,'Tustin');
            sps.A=Ad;
            sps.B=Bd;
            sps.C=Cd;
            sps.D=Dd;
        end


        j=0;
        for i=1:2:size(Ac,1)
            j=j+1;
            sps.A11(j)=sps.A(i,i);
            sps.A12(j)=sps.A(i,i+1);
            sps.A21(j)=sps.A(i+1,i);
            sps.A22(j)=sps.A(i+1,i+1);

            sps.B11(j)=sps.B(i,j);
            sps.B21(j)=sps.B(i+1,j);

            sps.C11(j)=sps.C(j,i);
            sps.C12(j)=sps.C(j,i+1);
        end


        if Initialize==1
            I=eye(size(Ac));
            sI1=I;
            sI2=I*1i*0;
            for ifilt=1:nfilt
                if size(Vac_Init,1)==1 ifilt2=1;else ifilt2=ifilt;end
                u1(ifilt,1)=Vac_Init(ifilt2,1)*exp(1i*Vac_Init(ifilt2,2)*pi/180);
                iline=2*ifilt-1;
                sI1(iline,iline)=1i*2*pi*Vac_Init(ifilt2,3);
                iline=iline+1;
                sI1(iline,iline)=1i*2*pi*Vac_Init(ifilt2,3);
                if length(Vdc_Init)==1 ifilt2=1;else ifilt2=ifilt;end
                u2(ifilt,1)=Vdc_Init(ifilt2)*exp(1i*90*pi/180);
            end

            u0=imag(u1+u2);

            x=inv(sI1-Ac)*Bc*u1+inv(sI2-Ac)*Bc*u2;
            x0c=imag(x);
            sps.x0=reshape(x0c,2,nfilt);
            switch WantBlockChoice

            case 'Discrete'
                x0d=(I-Ac*Ts/2)*x0c/Ts-Bc/2*u0;
                sps.x0=reshape(x0d,2,nfilt);
            end





            if nfilt==1&nInput>1
                I=eye(2,2);
                for iInput=1:nInput
                    u1=Vac_Init(iInput,1)*exp(1i*Vac_Init(iInput,2)*pi/180);
                    u2=Vdc_Init(iInput)*exp(1i*90*pi/180);
                    u0=imag(u1+u2);
                    sI1=eye(size(Ac))*1i*2*pi*Vac_Init(iInput,3);
                    sI2=eye(size(Ac))*0;
                    x=inv(sI1-Ac)*Bc*u1+inv(sI2-Ac)*Bc*u2;
                    x0c=imag(x);
                    sps.x0(:,iInput)=x0c;
                    switch WantBlockChoice

                    case 'Discrete'
                        x0d=(I-Ac*Ts/2)*x0c/Ts-Bc/2*u0;
                        sps.x0(:,iInput)=x0d;
                    end
                end
            end

        else
            sps.x0=zeros(2,1);
        end
    end
end

function SecondOrderFilterPlot(FilterType,Fo,Zeta,PlotResponse,FreqRange)

    if PlotResponse==1
        nfilt=length(Fo);
        color={'b','r','g','m','k'};
        F1=figure;
        F2=figure;

        str_legend=[];
        f=FreqRange(1):FreqRange(3):FreqRange(2);
        w=2*pi*f;
        Wo=2*pi*Fo;
        z_wn_min=min(Zeta.*Wo);
        t=0:1/z_wn_min/1000:7/z_wn_min;

        for ifilt=1:nfilt
            str_legend=[str_legend,sprintf('''Filter%d'',',ifilt)];
            if Zeta(ifilt)==1
                z=1+1e-12;
            else
                z=Zeta(ifilt);
            end
            wn=Wo(ifilt);

            switch FilterType
            case 1,
                Ystep=wn^2*(1/wn^2+1/(4*z^2*wn^2-4*wn^2)^(1/2)*(1/(-z*wn+1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*exp((-z*wn+1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*t)-1/(-z*wn-1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*exp((-z*wn-1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*t)));
                numFreq=wn^2;
            case 2,
                Ystep=-exp(-z*wn*t)/(z-1)/(z+1).*cos((-wn^2*(z-1)*(z+1))^(1/2)*t)+exp(-z*wn*t)/(z-1)/(z+1)*z^2.*cos((-wn^2*(z-1)*(z+1))^(1/2)*t)+z/wn*exp(-z*wn*t)/(z-1)/(z+1)*(wn^2-z^2*wn^2)^(1/2).*sin((-wn^2*(z-1)*(z+1))^(1/2)*t);
                numFreq=-w.^2;
            case 3,
                Ystep=2*z*wn/(4*z^2*wn^2-4*wn^2)^(1/2)*(exp((-z*wn+1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*t)-exp((-z*wn-1/2*(4*z^2*wn^2-4*wn^2)^(1/2))*t));
                numFreq=2*z*wn.*w*1i;
            case 4,
                Ystep=1+2*z/wn*exp(-z*wn*t)/(z-1)/(z+1)*(wn^2-z^2*wn^2)^(1/2).*sin((-wn^2*(z-1)*(z+1))^(1/2)*t);
                numFreq=wn^2-w.^2;
            end

            denFreq=(wn^2-w.^2)+2*z*wn*1i.*w;
            RepFreq=numFreq./denFreq;
            Mag=abs(RepFreq);
            Pha=angle(RepFreq)*180/pi;

            icolor=mod(ifilt,5);
            if icolor==0,icolor=5;end
            color_=color{icolor};


            figure(F1)
            subplot(2,1,1)
            plot(f,Mag,color_)
            hold on
            grid on
            title('Bode Diagram')
            ylabel('Magnitude')
            subplot(2,1,2)
            plot(f,Pha,color_)
            hold on
            ylabel('Phase (deg)')
            xlabel('Frequency (Hz)')
            grid on


            figure(F2)
            plot(t,real(Ystep),color_)
            hold on
            grid on
            ylabel('Amplitude')
            xlabel('Time (s)')
            title('Step Response')
        end

        if nfilt>1
            str_legend=['legend(',str_legend(1:end-1),')'];
            figure(F1)
            eval(str_legend)
            figure(F2)
            eval(str_legend)
        end

        set_param(gcb,'PlotResponse','off')
    end
end

function SecondOrderFilterCback(block)
    if strcmp(get_param(block,'Initialize'),'on')
        visible={'on','on','on','on','on','on','on','on',get_param(block,'PlotResponse')};
    else
        visible={'on','on','on','on','on','off','off','on',get_param(block,'PlotResponse')};
    end
    set_param(block,'MaskVisibilities',visible)

    if strcmp(get_param(block,'PlotResponse'),'on')
        visible={'on','on','on','on','on',get_param(block,'Initialize'),get_param(block,'Initialize'),'on','on'};
    else
        visible={'on','on','on','on','on',get_param(block,'Initialize'),get_param(block,'Initialize'),'on','off'};
    end
    set_param(block,'MaskVisibilities',visible)
end
