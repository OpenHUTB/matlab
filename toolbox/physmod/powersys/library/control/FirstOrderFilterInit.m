function[WantBlockChoice,Ts,sps]=FirstOrderFilterInit(varargin)






    if size(varargin,2)>4
        [block,FilterType,Tc,Initialize,Vac_Init,Vdc_Init,Ts]=varargin{1:end};
    elseif size(varargin,2)==4
        [FilterType,Tc,PlotResponse,FreqRange]=varargin{1:end};
        FirstOrderFilterPlot(FilterType,Tc,PlotResponse,FreqRange);
        return;
    else
        block=varargin{1};

        if strcmp(get_param(block,'Initialize'),'on')
            visible={'on','on','on','on','on','on','on',get_param(block,'PlotResponse')};
        else
            visible={'on','on','on','on','off','off','on',get_param(block,'PlotResponse')};
        end
        set_param(block,'MaskVisibilities',visible);

        if strcmp(get_param(block,'PlotResponse'),'on')
            visible={'on','on','on','on',get_param(block,'Initialize'),get_param(block,'Initialize'),'on','on'};
        else
            visible={'on','on','on','on',get_param(block,'Initialize'),get_param(block,'Initialize'),'on','off'};
        end
        set_param(block,'MaskVisibilities',visible);

        return;
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    nfilt=length(Tc);
    sps.A=[];
    sps.B=[];
    sps.C=[];
    sps.D=eye(nfilt,nfilt);
    sps.x0=0;
    sps.X=[];
    sps.Y=[];

    switch FilterType
    case 1
        sps.X=[0,1,2,3,4];
        sps.Y=[-1,-1,-2.5,-4,-4];
    case 2
        sps.X=[0,1,2,3,4];
        sps.Y=[-4,-4,-2.5,-1,-1];
    end

    if Init

        BK=strrep(block,char(10),char(32));

        if any(Tc<0)
            error(message('physmod:powersys:common:GreaterThanOrEqualTo',BK,'Time constant(s)','0'));
        end

        if Initialize&&size(Vac_Init,2)~=3
            error(message('physmod:powersys:common:InvalidVectorParameter','AC initial input',BK,num2str(length(Tc)),'3'));
        end

        if Initialize&&~(length(Tc)==size(Vac_Init,1)||length(Tc)==1||size(Vac_Init,1)==1)
            error(message('physmod:powersys:common:InvalidVectorParameter','AC initial input',BK,num2str(length(Tc)),'3'));
        end

        if Initialize&&~(length(Tc)==length(Vdc_Init)||length(Tc)==1||length(Vdc_Init)==1)
            error(message('physmod:powersys:common:InvalidVectorParameter','DC initial input',BK,'1',num2str(length(Tc))));
        end

        if Initialize&&~(size(Vac_Init,1)==length(Vdc_Init))
            error(message('physmod:powersys:common:InvalidVectorParameter','DC initial input',BK,'1',num2str(length(Tc))));
        end




        nInput=size(Vac_Init,1);
        nstates=0;
        for ifilt=1:nfilt

            if Tc(ifilt)~=0
                switch WantBlockChoice
                case 'Discrete'

                    Tc(ifilt)=Ts/(2*tan(Ts/(2*Tc(ifilt))));
                end
                nstates=nstates+1;
                Ac(nstates,nstates)=-1/Tc(ifilt);
                Bc(nstates,ifilt)=1/Tc(ifilt);
            end
            switch FilterType
            case 1
                if Tc(ifilt)~=0
                    Cc(ifilt,nstates)=1;
                    Dc(ifilt,ifilt)=0;
                else
                    Dc(ifilt,ifilt)=1;
                end
            case 2
                if Tc(ifilt)~=0
                    Cc(ifilt,nstates)=-1;
                    Dc(ifilt,ifilt)=1;
                else
                    Dc(ifilt,ifilt)=0;
                end
            end
        end
        if nstates==0
            Ac=0;Bc=0;Cc=0;
        end


        if nstates>0
            switch WantBlockChoice
            case 'Continuous'
                sps.A=Ac;
                sps.B=Bc;
                sps.C=Cc;
                sps.D=Dc;
            case 'Discrete'
                [Ad,Bd,Cd,Dd]=powericon('psb_c2d',Ac,Bc,Cc,Dc,Ts,'Tustin');
                sps.A=Ad;
                sps.B=Bd;
                sps.C=Cd;
                sps.D=Dd;
            end
        else



            sps.A=0;
            sps.B=0;
            sps.C=0;
            sps.D=Dc;
        end


        if nstates>0&&Initialize==1
            istate=0;
            I=eye(size(Ac));
            sI1=I;
            sI2=I*1i*0;
            for ifilt=1:nfilt
                if size(Vac_Init,1)==1
                    ifilt2=1;
                else
                    ifilt2=ifilt;
                end
                u1(ifilt,1)=Vac_Init(ifilt2,1)*exp(1i*Vac_Init(ifilt2,2)*pi/180);
                if Tc(ifilt)>0
                    istate=istate+1;
                    sI1(istate,istate)=1i*2*pi*Vac_Init(ifilt2,3);
                end

                if length(Vdc_Init)==1
                    ifilt2=1;
                else
                    ifilt2=ifilt;
                end
                u2(ifilt,1)=Vdc_Init(ifilt2)*exp(1i*90*pi/180);
            end

            u0=imag(u1+u2);
            x=inv(sI1-Ac)*Bc*u1+inv(sI2-Ac)*Bc*u2;





            if nfilt==1&&nInput>1
                for iInput=1:nInput
                    u1=Vac_Init(iInput,1)*exp(1i*Vac_Init(iInput,2)*pi/180);
                    u2=Vdc_Init(iInput)*exp(1i*90*pi/180);
                    u0(iInput,1)=imag(u1+u2);
                    sI1=1i*2*pi*Vac_Init(iInput,3);
                    sI2=0;
                    x(iInput,1)=inv(sI1-Ac)*Bc*u1+inv(sI2-Ac)*Bc*u2;
                end
            end

            sps.x0=imag(x);
            switch WantBlockChoice

            case 'Discrete'
                sps.x0=(I-Ac*Ts/2)*sps.x0/Ts-Bc/2*u0;
            end
        else
            sps.x0=0;
        end
    end

    function FirstOrderFilterPlot(FilterType,Tc,PlotResponse,FreqRange)

        if PlotResponse==1
            nfilt=length(Tc);
            color={'b','r','g','m','k'};
            F1=figure;
            F2=figure;
            str_legend=[];
            f=FreqRange(1):FreqRange(3):FreqRange(2);
            w=2*pi*f;

            for ifilt=1:nfilt
                if Tc(ifilt)>0
                    t=0:Tc(ifilt)/1000:7*Tc(ifilt);
                else
                    if all(Tc==0)
                        t=[eps,1];
                    else
                        t=[0,max(7*Tc)];
                    end
                end

                str_legend=[str_legend,sprintf('''Filter%d'',',ifilt)];
                switch FilterType
                case 1
                    if Tc(ifilt)==0
                        Ystep=ones(size(t));
                    else
                        Ystep=1-exp(-t/Tc(ifilt));
                    end
                    RepFreq=1./(1+Tc(ifilt)*1i.*w);
                case 2
                    if Tc(ifilt)==0
                        Ystep=zeros(size(t));
                    else
                        Ystep=exp(-t/Tc(ifilt));
                    end
                    RepFreq=1./(1+(1./(Tc(ifilt)*1i.*w)));
                end

                Mag=abs(RepFreq);
                Pha=angle(RepFreq)*180/pi;

                icolor=mod(ifilt,5);
                if icolor==0,icolor=5;end
                color_=color{icolor};


                figure(F1)
                subplot(2,1,1)
                plot(f,Mag,color_)
                hold on
                title('Bode Diagram')
                ylabel('Magnitude')
                grid on
                subplot(2,1,2)
                plot(f,Pha,color_)
                hold on
                ylabel('Phase (deg)')
                xlabel('Frequency (Hz)')
                grid on


                figure(F2)
                plot(t,Ystep,color_)
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
