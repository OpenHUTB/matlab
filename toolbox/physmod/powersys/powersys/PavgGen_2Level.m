function[g,D,Ton,Toff]=PavgGen_2Level(Ts,Fc,Vref,Clk)%#codegen
    coder.allowpcode('plain');








    dataType='double';
    D=zeros(3,1,dataType);
    g=zeros(6,1,dataType);
    Ton=zeros(3,1,dataType);
    Toff=zeros(3,1,dataType);
    TS=Ts*Fc;

    for n=1:3
        D(n)=(Vref(n)+1)/2;
        Ton(n)=0.5-D(n)/2;
        Toff(n)=Ton(n)+D(n);
    end


    time=rem(Clk,1/Fc)*Fc;


    for n=1:3
        if time>=Ton(n)&&Toff(n)>time
            g(n)=1;
        elseif(time+TS)>Ton(n)&&Toff(n)>time
            g(n)=((time+TS)-Ton(n))/TS;
        end
        if time>=Toff(n)
            g(n)=0;
        elseif(time+TS)>Toff(n)
            g(n)=(Toff(n)-time)/TS;
        end

        if(time+TS)>1
            if(Ton(n)+1)<(time+TS)
                g(n)=((time+TS)-(Ton(n)+1))/TS;
                if(time+TS)>Toff(n)&&time<Toff(n)
                    g(n)=((time+TS)-(Ton(n)+1))/TS+(Toff(n)-time)/TS;
                end
            end
        end

        if time<0.5&&(time+TS)>0.5&&Toff(n)<(time+TS)&&time<Ton(n)
            g(n)=(Toff(n)-Ton(n))/TS;
        end

    end

    for n=1:3
        g(3+n)=1-g(n);
    end






