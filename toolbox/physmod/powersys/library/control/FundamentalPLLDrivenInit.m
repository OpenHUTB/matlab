function[WantBlockChoice,Ts,sps]=FundamentalPLLDrivenInit(block,Finit,Fmin,InInit,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init
        BK=strrep(block,char(10),char(32));

        if any(Finit<=0)
            error(message('physmod:powersys:common:GreaterThan',BK,'Fundamental frequency(Hz)','0'));
        end
        if any(Fmin<=0)
            error(message('physmod:powersys:common:GreaterThan',BK,'Minimum frequency(Hz)','0'));
        end
        if size(InInit,2)~=2
            error(message('physmod:powersys:common:InvalidVectorParameter','Initial input [Mag, Phase-relative-to-PLL(degrees)]',BK,'1','2'));
        end

        sps.Finit=Finit;
        sps.Fmin=Fmin;
        sps.Real_Init=InInit(:,1).*cos(pi/180.*InInit(:,2));
        sps.Imag_Init=InInit(:,1).*sin(pi/180.*InInit(:,2));
    end