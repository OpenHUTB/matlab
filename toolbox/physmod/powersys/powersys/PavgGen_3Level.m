function[g]=PavgGen_3Level(Ts,Fc,VrefA,VrefB,VrefC,Clk)%#codegen
    coder.allowpcode('plain');








    dataType='double';
    time=zeros(2,1,dataType);
    g=zeros(12,1,dataType);
    gA=zeros(2,1,dataType);
    gB=zeros(2,1,dataType);
    gC=zeros(2,1,dataType);
    DA=zeros(2,1,dataType);
    DB=zeros(2,1,dataType);
    DC=zeros(2,1,dataType);
    TonA=zeros(2,1,dataType);
    TonB=zeros(2,1,dataType);
    TonC=zeros(2,1,dataType);
    ToffA=zeros(2,1,dataType);
    ToffB=zeros(2,1,dataType);
    ToffC=zeros(2,1,dataType);
    TS=Ts*Fc;

    time(1)=rem(Clk(1),1/Fc)*Fc;
    time(2)=rem(Clk(2),1/Fc)*Fc;



    if VrefA>=0
        DA(1)=VrefA;
        DA(2)=0;
    else
        DA(1)=0;
        DA(2)=-VrefA;
    end
    for n=1:2
        TonA(n)=0.5-(1-DA(n))/2;
        ToffA(n)=0.5+(1-DA(n))/2;
    end


    for n=1:2
        if time(n)>=TonA(n)&&time(n)<ToffA(n)
            gA(n)=1;
        elseif(time(n)+TS)>TonA(n)&&ToffA(n)>time(n)
            gA(n)=((time(n)+TS)-TonA(n))/TS;
        end
        if time(n)>=ToffA(n)
            gA(n)=0;
        elseif(time(n)+TS)>ToffA(n)
            gA(n)=(ToffA(n)-time(n))/TS;
        end

        if(time(n)+TS)>1
            if(TonA(n)+1)<(time(n)+TS)
                gA(n)=((time(n)+TS)-(TonA(n)+1))/TS;
                if(time(n)+TS)>ToffA(n)&&time(n)<ToffA(n)
                    gA(n)=((time(n)+TS)-(TonA(n)+1))/TS+(ToffA(n)-time(n))/TS;
                end
            end
        end

        if time(n)<0.5&&(time(n)+TS)>0.5&&ToffA(n)<(time(n)+TS)&&time(n)<TonA(n)
            g(n)=(ToffA(n)-TonA(n))/TS;
        end

        if ToffA(n)>=0.9999
            gA(n)=1;
        end
    end

    g(3)=gA(1);
    g(2)=gA(2);
    g(1)=1-gA(1);
    g(4)=1-gA(2);


    if VrefB>=0
        DB(1)=VrefB;
        DB(2)=0;
    else
        DB(1)=0;
        DB(2)=-VrefB;
    end
    for n=1:2
        TonB(n)=0.5-(1-DB(n))/2;
        ToffB(n)=0.5+(1-DB(n))/2;
    end


    for n=1:2
        if time(n)>=TonB(n)&&time(n)<ToffB(n)
            gB(n)=1;
        elseif(time(n)+TS)>TonB(n)&&ToffB(n)>time(n)
            gB(n)=((time(n)+TS)-TonB(n))/TS;
        end
        if time(n)>=ToffB(n)
            gB(n)=0;
        elseif(time(n)+TS)>ToffB(n)
            gB(n)=(ToffB(n)-time(n))/TS;
        end

        if(time(n)+TS)>1
            if(TonB(n)+1)<(time(n)+TS)
                gB(n)=((time(n)+TS)-(TonB(n)+1))/TS;
                if(time(n)+TS)>ToffB(n)&&time(n)<ToffB(n)
                    gB(n)=((time(n)+TS)-(TonB(n)+1))/TS+(ToffB(n)-time(n))/TS;
                end
            end
        end

        if time(n)<0.5&&(time(n)+TS)>0.5&&ToffB(n)<(time(n)+TS)&&time(n)<TonB(n)
            gB(n)=(ToffB(n)-TonB(n))/TS;
        end

        if ToffB(n)>=0.9999
            gB(n)=1;
        end
    end

    g(7)=gB(1);
    g(6)=gB(2);
    g(5)=1-g(7);
    g(8)=1-g(6);


    if VrefC>=0
        DC(1)=VrefC;
        DC(2)=0;
    else
        DC(1)=0;
        DC(2)=-VrefC;
    end
    for n=1:2
        TonC(n)=0.5-(1-DC(n))/2;
        ToffC(n)=0.5+(1-DC(n))/2;
    end


    for n=1:2
        if time(n)>=TonC(n)&&time(n)<ToffC(n)
            gC(n)=1;
        elseif(time(n)+TS)>TonC(n)&&ToffC(n)>time(n)
            gC(n)=((time(n)+TS)-TonC(n))/TS;
        end
        if time(n)>=ToffC(n)
            gC(n)=0;
        elseif(time(n)+TS)>ToffC(n)
            gC(n)=(ToffC(n)-time(n))/TS;
        end

        if(time(n)+TS)>1
            if(TonC(n)+1)<(time(n)+TS)
                gC(n)=((time(n)+TS)-(TonC(n)+1))/TS;
                if(time(n)+TS)>ToffC(n)&&time(n)<ToffC(n)
                    gC(n)=((time(n)+TS)-(TonC(n)+1))/TS+(ToffC(n)-time(n))/TS;
                end
            end
        end

        if time(n)<0.5&&(time(n)+TS)>0.5&&ToffC(n)<(time(n)+TS)&&time(n)<TonC(n)
            gC(n)=(ToffC(n)-TonC(n))/TS;
        end
        if ToffC(n)>=0.9999
            gC(n)=1;
        end

    end

    g(11)=gC(1);
    g(10)=gC(2);
    g(9)=1-g(11);
    g(12)=1-g(10);








