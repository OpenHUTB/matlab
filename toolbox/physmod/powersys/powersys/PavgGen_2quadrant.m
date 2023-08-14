function[g,Ton,Toff]=PavgGen_2quadrant(Ts,Fc,D,Clk)%#codegen
    coder.allowpcode('plain');








    dataType='double';
    g=zeros(2,1,dataType);
    Ton=zeros(1,1,dataType);
    Toff=zeros(1,1,dataType);
    TS=Ts*Fc;

    Ton(1)=0.5-D/2;
    Toff(1)=Ton(1)+D;


    time=rem(Clk,1/Fc)*Fc;


    for n=1:1
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

    g(2)=1-g(1);






