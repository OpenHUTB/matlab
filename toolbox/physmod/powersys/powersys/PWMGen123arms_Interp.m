function[P,DelayOn,DelayOff]=PWMGen123arms_Interp(Ts,Fc,InitialPhase,Vref,NumberOfPulses,NumberOfArms)%#codegen
    coder.allowpcode('plain');
















    dataType='double';
    persistent StateOld CrOld Slope VrefOld TS
    if isempty(StateOld)
        StateOld=zeros(NumberOfArms,1,dataType);
        VrefOld=zeros(NumberOfArms,1,dataType);
        TS=Ts*Fc*4;

        Phase=mod(InitialPhase,360);
        if Phase<180
            Slope=1;
            CrOld=-1+2*(Phase/180)-TS;
        else
            Slope=-1;
            CrOld=(1-2*(Phase-180)/180)+TS;
        end
    end

    Cr=0;
    State=zeros(NumberOfArms,1,dataType);
    P=zeros(NumberOfPulses,1,dataType);
    DelayOn=zeros(NumberOfPulses,1,dataType);
    DelayOnP=zeros(NumberOfArms,1,dataType);
    DelayOff=zeros(NumberOfPulses,1,dataType);
    DelayOffP=zeros(NumberOfArms,1,dataType);
    TransPM=zeros(1,1,dataType);
    TransMP=zeros(1,1,dataType);



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



    for n=1:NumberOfArms
        if Vref(n)>=Cr
            State(n)=1;
        else
            State(n)=0;
        end
    end


    for n=1:NumberOfArms
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

        elseif((StateOld(n)==1&&State(n)==1)&&(TransPM==1)&&(VrefOld(n)~=1.0))
            DelayOffP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld+TS)-CrOld+VrefOld(n)-Vref(n)));
            DelayOnP(n)=Ts-((VrefOld(n)-(Cr+TS))*Ts/(Cr-(Cr+TS)+VrefOld(n)-Vref(n)));
        elseif((StateOld(n)==0&&State(n)==0)&&(TransMP==1)&&(VrefOld(n)~=-1))
            DelayOnP(n)=Ts-((VrefOld(n)-CrOld)*Ts/((CrOld-TS)-CrOld+VrefOld(n)-Vref(n)));
            DelayOffP(n)=Ts-((VrefOld(n)-(Cr-TS))*Ts/(Cr-(Cr-TS)+VrefOld(n)-Vref(n)));
        else
            DelayOnP(n)=0;
            DelayOffP(n)=0;
        end
    end


    for n=1:NumberOfArms
        if(State(n)==1)
            P(1+2*(n-1))=1;P(2+2*(n-1))=0;
        else
            P(1+2*(n-1))=0;P(2+2*(n-1))=1;
        end
    end


    for n=1:NumberOfArms
        DelayOn(1+2*(n-1))=DelayOnP(n);
        DelayOn(2+2*(n-1))=DelayOffP(n);
        DelayOff(1+2*(n-1))=DelayOffP(n);
        DelayOff(2+2*(n-1))=DelayOnP(n);
    end




    for n=1:NumberOfArms
        StateOld(n)=State(n);
        VrefOld(n)=Vref(n);
    end
    CrOld=Cr;