function[P,D]=unifiedPWMModulator2Level(Ts,Fsw,Vref,PWMmethod,Pavg,Clk)%#codegen
    coder.allowpcode('plain');


























    dataType='double';
    persistent StateOld CrOld Slope VrefOld TS
    if isempty(StateOld)
        StateOld=zeros(3,1,dataType);
        VrefOld=zeros(3,1,dataType);
        TS=Ts*Fsw*4;

        Phase=mod(110,360);
        if Phase<180
            Slope=1;
            CrOld=-1+2*(Phase/180)-TS;
        else
            Slope=-1;
            CrOld=(1-2*(Phase-180)/180)+TS;
        end
    end

    D=zeros(3,1,dataType);
    Cr=0;
    State=zeros(3,1,dataType);
    P=zeros(6,1,dataType);
    DelayOn=zeros(6,1,dataType);
    DelayOnP=zeros(3,1,dataType);
    DelayOff=zeros(6,1,dataType);
    DelayOffP=zeros(3,1,dataType);
    TransPM=zeros(1,1,dataType);
    TransMP=zeros(1,1,dataType);
    Ton=zeros(3,1,dataType);
    Toff=zeros(3,1,dataType);

    Tg=zeros(3,1,dataType);
    T_img=zeros(3,1,dataType);



    Tsamp=1/Fsw/2;


    for n=1:3
        T_img(n)=Tsamp*Vref(n)/2;
    end


    Tmax=max(T_img);
    Tmin=min(T_img);


    Teff=Tmax-Tmin;
    Tzero=Tsamp-Teff;

    switch PWMmethod
    case 1
        Toffset=Tsamp/2;
    case 2
        Toffset=Tsamp/2;
    case 3
        Toffset=Tzero/2-Tmin;
    case 4
        Toffset=Tzero/2-Tmin;
    case 5
        if(Tmin+Tmax)>=0
            Toffset=-Tmin;
        else
            Toffset=Tsamp-Tmax;
        end
    end


    for n=1:3
        Tg(n)=(T_img(n)+Toffset);
        D(n)=Tg(n)*Fsw*2;
        Vref(n)=2*D(n)-1;
    end
    if Pavg==0

        for n=1:3
            Ton(n)=Tsamp-Tg(n);
            if Ton(n)<0
                Ton(n)=0;
            end
            if Ton(n)>Tsamp
                Ton(n)=Tsamp;
            end
            Toff(n)=Tg(n)+Tsamp;
            if Toff(n)>(2*Tsamp)
                Toff(n)=(2*Tsamp);
            end
            if Toff(n)<Tsamp
                Toff(n)=Tsamp;
            end
        end



        time=rem(Clk,Tsamp*2);


        for n=1:3
            if time>=Ton(n)&&Toff(n)>time
                P(n)=1;
            else
                P(n)=0;
            end
        end


        P(5)=P(3);
        P(3)=P(2);
        P(2)=1-P(1);
        P(4)=1-P(3);
        P(6)=1-P(5);

    else


        if Slope==1
            Cr=CrOld+TS;
            if Cr>1
                Cr=2-Cr;
                Slope=-1;
                TransPM=1;
            end
        elseif Slope==-1
            Cr=CrOld-TS;
            if Cr<-1
                Cr=-2-Cr;
                Slope=1;
                TransMP=1;
            end
        end



        for n=1:3
            if Vref(n)>=Cr
                State(n)=1;
            else
                State(n)=0;
            end
        end


        for n=1:3
            if(StateOld(n)==1&&State(n)==0)
                if(TransPM==0&&TransMP==0)
                    DelayOnP(n)=0;
                    DelayOffP(n)=Ts-((VrefOld(n)-CrOld)*Ts/(Cr-CrOld+VrefOld(n)-Vref(n)));
                elseif(TransPM==1)
                    DelayOnP(n)=0;
                    DelayOffP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld+TS)-CrOld+VrefOld(n)-Vref(n)));
                else
                    DelayOnP(n)=0;
                    DelayOffP(n)=Ts-((VrefOld(n)-(Cr-TS))*Ts/(Cr-(Cr-TS)+VrefOld(n)-Vref(n)));
                end
                P(1+2*(n-1))=(Ts-DelayOffP(n))/Ts;
                P(2+2*(n-1))=1-P(1+2*(n-1));
            elseif(StateOld(n)==0&&State(n)==1)
                if(TransPM==0&&TransMP==0)
                    DelayOnP(n)=Ts-((VrefOld(n)-CrOld)*Ts/(Cr-CrOld+VrefOld(n)-Vref(n)));
                    DelayOffP(n)=0;
                elseif(TransPM==1)
                    DelayOnP(n)=Ts-((VrefOld(n)-(Cr+TS))*Ts/(Cr-(Cr+TS)+VrefOld(n)-Vref(n)));
                    DelayOffP(n)=0;
                else
                    DelayOnP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld-TS)-CrOld+VrefOld(n)-Vref(n)));
                    DelayOffP(n)=0;
                end
                P(1+2*(n-1))=DelayOnP(n)/Ts;
                P(2+2*(n-1))=1-P(1+2*(n-1));

            elseif((StateOld(n)==1&&State(n)==1)&&(TransPM==1)&&(VrefOld(n)~=1.0))
                DelayOffP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld+TS)-CrOld+VrefOld(n)-Vref(n)));
                DelayOnP(n)=Ts-((VrefOld(n)-(Cr+TS))*Ts/(Cr-(Cr+TS)+VrefOld(n)-Vref(n)));
                P(1+2*(n-1))=1-(DelayOffP(n)-DelayOnP(n))/Ts;
                P(2+2*(n-1))=1-P(1+2*(n-1));
            elseif((StateOld(n)==0&&State(n)==0)&&(TransMP==1)&&(VrefOld(n)~=-1))
                DelayOnP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld-TS)-CrOld+VrefOld(n)-Vref(n)));
                DelayOffP(n)=Ts-((VrefOld(n)-(Cr-TS))*Ts/(Cr-(Cr-TS)+VrefOld(n)-Vref(n)));
                P(1+2*(n-1))=(DelayOnP(n)-DelayOffP(n))/Ts;
                P(2+2*(n-1))=1-P(1+2*(n-1));
            else
                DelayOnP(n)=0;
                DelayOffP(n)=0;
                if(State(n)==1)
                    P(1+2*(n-1))=1;
                    P(2+2*(n-1))=0;
                else
                    P(1+2*(n-1))=0;
                    P(2+2*(n-1))=1;
                end
            end
        end


        for n=1:3
            DelayOn(1+2*(n-1))=DelayOnP(n);
            DelayOn(2+2*(n-1))=DelayOffP(n);
            DelayOff(1+2*(n-1))=DelayOffP(n);
            DelayOff(2+2*(n-1))=DelayOnP(n);
        end




        for n=1:3
            StateOld(n)=State(n);
            VrefOld(n)=Vref(n);
        end
        CrOld=Cr;
    end