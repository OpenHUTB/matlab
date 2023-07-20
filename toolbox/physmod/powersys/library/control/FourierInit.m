function[WantBlockChoice,Ts,sps]=FourierInit(block,Freq,n,Par_Init,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init
        BK=strrep(block,char(10),char(32));

        if any(Freq<=0)
            error(message('physmod:powersys:common:GreaterThan',BK,'Fundamental frequency(Hz)','0'));
        end
        if any(n<0)
            error(message('physmod:powersys:common:GreaterThanOrEqualTo',BK,'Harmonic n','0'));
        end
        if size(Par_Init,2)~=2
            error(message('physmod:powersys:common:InvalidVectorParameter','Initial input [Mag, Phase(degrees)]',BK,'1','2'));
        end

        sps.Freq=Freq;
        sps.n=n;
        sps.k=2-(n==0);
        sps.Real_Init=Par_Init(:,1).*cos(pi/180.*Par_Init(:,2));
        sps.Imag_Init=Par_Init(:,1).*sin(pi/180.*Par_Init(:,2));
    end