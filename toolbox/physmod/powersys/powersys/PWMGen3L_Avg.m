function[P]=PWMGen3L_Avg(Ts,Fc,InitialPhase,Vref)%#codegen
    coder.allowpcode('plain');
















    dataType='double';
    persistent StateOld CplusOld CminusOld Slope VrefOld TS
    if isempty(StateOld)
        StateOld=zeros(3,1,dataType);
        VrefOld=zeros(3,1,dataType);
        TS=Ts*Fc*2;

        Phase=mod(InitialPhase,360);
        if Phase<180
            Slope=1;
            CplusOld=(Phase/180)-TS;
        else
            Slope=-1;
            CplusOld=(1-(Phase-180)/180)+TS;
        end
        CminusOld=-CplusOld;
    end

    Cplus=0;
    State=zeros(3,1,dataType);
    P=zeros(12,1,dataType);

    DelayOnP=zeros(3,1,dataType);
    DelayOnM=zeros(3,1,dataType);

    DelayOffP=zeros(3,1,dataType);
    DelayOffM=zeros(3,1,dataType);
    TransPM=zeros(1,1,dataType);
    TransMP=zeros(1,1,dataType);



    if Slope==1
        Cplus=CplusOld+TS;
        if Cplus>1
            Cplus=2-Cplus;
            Slope=-1;
            TransPM=1;
        end
    elseif Slope==-1
        Cplus=CplusOld-TS;
        if Cplus<0
            Cplus=-Cplus;
            Slope=1;
            TransMP=1;
        end
    end
    Cminus=Cplus-1;



    for n=1:3
        if Vref(n)>=Cplus
            State(n)=1;
        elseif Vref(n)<=Cminus
            State(n)=-1;
        else
            State(n)=0;
        end
    end


    for n=1:3
        if(StateOld(n)==1&&State(n)==0)
            if(TransPM==0&&TransMP==0)
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/(Cplus-CplusOld+VrefOld(n)-Vref(n)));
                DelayOffM(n)=0;
            elseif(TransPM==1)
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/((CplusOld+TS)-CplusOld+VrefOld(n)-Vref(n)));
                DelayOffM(n)=0;
            else
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=Ts-((VrefOld(n)-(Cplus-TS))*Ts/(Cplus-(Cplus-TS)+VrefOld(n)-Vref(n)));
                DelayOffM(n)=0;
            end
            P(1+4*(n-1))=(Ts-DelayOffP(n))/Ts;
            P(4+4*(n-1))=0;
        elseif(StateOld(n)==0&&State(n)==1)
            if(TransPM==0&&TransMP==0)
                DelayOnP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/(Cplus-CplusOld+VrefOld(n)-Vref(n)));
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            elseif(TransPM==1)
                DelayOnP(n)=Ts-((VrefOld(n)-(Cplus+TS))*Ts/(Cplus-(Cplus+TS)+VrefOld(n)-Vref(n)));
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            else
                DelayOnP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/((CplusOld-TS)-CplusOld+VrefOld(n)-Vref(n)));
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            end
            P(1+4*(n-1))=DelayOnP(n)/Ts;
            P(4+4*(n-1))=0;
        elseif(StateOld(n)==-1&&State(n)==0)
            if(TransPM==0&&TransMP==0)
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/(Cminus-CminusOld+VrefOld(n)-Vref(n)));
            elseif(TransPM==1)
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=Ts-((VrefOld(n)-(Cminus+TS))*Ts/(Cminus-(Cminus+TS)+VrefOld(n)-Vref(n)));
            else
                DelayOnP(n)=0;
                DelayOnM(n)=0;
                DelayOffP(n)=0;
                DelayOffM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/((CminusOld-TS)-CminusOld+VrefOld(n)-Vref(n)));
            end
            P(1+4*(n-1))=0;
            P(4+4*(n-1))=(Ts-DelayOffM(n))/Ts;
        elseif(StateOld(n)==0&&State(n)==-1)
            if(TransPM==0&&TransMP==0)
                DelayOnP(n)=0;
                DelayOnM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/(Cminus-CminusOld+VrefOld(n)-Vref(n)));
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            elseif(TransPM==1)
                DelayOnP(n)=0;
                DelayOnM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/((CminusOld+TS)-CminusOld+VrefOld(n)-Vref(n)));
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            else
                DelayOnP(n)=0;
                DelayOnM(n)=Ts-((VrefOld(n)-(Cminus-TS))*Ts/(Cminus-(Cminus-TS)+VrefOld(n)-Vref(n)));
                DelayOffP(n)=0;
                DelayOffM(n)=0;
            end
            P(1+4*(n-1))=0;
            P(4+4*(n-1))=DelayOnM(n)/Ts;

        elseif((StateOld(n)==1&&State(n)==1)&&(TransPM==1)&&(VrefOld(n)~=1.0))
            DelayOffP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/((CplusOld+TS)-CplusOld+VrefOld(n)-Vref(n)));
            DelayOnP(n)=Ts-((VrefOld(n)-(Cplus+TS))*Ts/(Cplus-(Cplus+TS)+VrefOld(n)-Vref(n)));
            P(1+4*(n-1))=1-(DelayOffP(n)-DelayOnP(n))/Ts;
            P(4+4*(n-1))=0;
        elseif((StateOld(n)==0&&State(n)==0)&&(TransMP==1)&&(VrefOld(n)>0.0))
            DelayOnP(n)=Ts-((VrefOld(n)-CplusOld)*Ts/((CplusOld-TS)-CplusOld+VrefOld(n)-Vref(n)));
            DelayOffP(n)=Ts-((VrefOld(n)-(Cplus-TS))*Ts/(Cplus-(Cplus-TS)+VrefOld(n)-Vref(n)));
            P(1+4*(n-1))=(DelayOnP(n)-DelayOffP(n))/Ts;
            P(4+4*(n-1))=0;
        elseif((StateOld(n)==0&&State(n)==0)&&(TransPM==1)&&(VrefOld(n)<0.0))
            DelayOnM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/((CminusOld+TS)-CminusOld+VrefOld(n)-Vref(n)));
            DelayOffM(n)=Ts-((VrefOld(n)-(Cminus+TS))*Ts/(Cminus-(Cminus+TS)+VrefOld(n)-Vref(n)));
            P(1+4*(n-1))=0;
            P(4+4*(n-1))=(DelayOnM(n)-DelayOffM(n))/Ts;
        elseif((StateOld(n)==-1&&State(n)==-1)&&(TransMP==1)&&(VrefOld(n)~=0.0))
            DelayOffM(n)=Ts-((VrefOld(n)-CminusOld)*Ts/((CminusOld-TS)-CminusOld+VrefOld(n)-Vref(n)));
            DelayOnM(n)=Ts-((VrefOld(n)-(Cminus-TS))*Ts/(Cminus-(Cminus-TS)+VrefOld(n)-Vref(n)));
            P(1+4*(n-1))=0;
            P(4+4*(n-1))=1-(DelayOffM(n)-DelayOnM(n))/Ts;
        else
            DelayOnP(n)=0;
            DelayOnM(n)=0;
            DelayOffP(n)=0;
            DelayOffM(n)=0;
            if(State(n)==1)
                P(1+4*(n-1))=1;
                P(4+4*(n-1))=0;
            elseif(State(n)==-1)
                P(1+4*(n-1))=0;
                P(4+4*(n-1))=1;
            else
                P(1+4*(n-1))=0;
                P(4+4*(n-1))=0;
            end
        end
    end
    for n=1:3
        if(VrefOld(n)==0&&Vref(n)==0)
            State(n)=0;
            DelayOnP(n)=0;
            DelayOnM(n)=0;
            DelayOffP(n)=0;
            DelayOffM(n)=0;
            P(1+4*(n-1))=0;
            P(4+4*(n-1))=0;
        end
    end






























    for n=1:3
        P(2+4*(n-1))=1-P(4+4*(n-1));
        P(3+4*(n-1))=1-P(1+4*(n-1));
    end



    for n=1:3
        StateOld(n)=State(n);
        VrefOld(n)=Vref(n);
    end
    CplusOld=Cplus;
    CminusOld=Cminus;









