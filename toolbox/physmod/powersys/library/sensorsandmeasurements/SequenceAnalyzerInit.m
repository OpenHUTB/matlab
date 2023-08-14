function[WantBlockChoice,Ts,sps]=SequenceAnalyzerInit(block,Freq,n,seq,Par_Init,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);

    if Init

        Erreur.identifier='SpecializedPowerSystems:SequenceAnalyzerBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Freq<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Fundamental frequency must be >0.',BK);
            psberror(Erreur);
            return
        end
        if any(n<0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Harmonic number cannot be negative.',BK);
            psberror(Erreur);
            return
        end

        sps.Freq=Freq;
        sps.n=n;
        sps.a=exp(1i*2*pi/3);
        sps.a2=exp(-1i*2*pi/3);
        switch seq
        case 1,
            sps.PosOn=1;sps.NegOn=0;sps.ZeroOn=0;sps.SelectElement=1;
        case 2,
            sps.PosOn=0;sps.NegOn=1;sps.ZeroOn=0;sps.SelectElement=2;
        case 3,
            sps.PosOn=0;sps.NegOn=0;sps.ZeroOn=1;sps.SelectElement=3;
        case 4,
            sps.PosOn=1;sps.NegOn=1;sps.ZeroOn=1;sps.SelectElement=[1,2,3];
        end
        sps.Par_Init=Par_Init;

    end