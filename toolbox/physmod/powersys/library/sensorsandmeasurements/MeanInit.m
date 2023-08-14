function[WantBlockChoice,Ts,sps]=MeanInit(block,Freq,Vinit,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init
        if any(Freq<=0)
            BK=strrep(block,char(10),char(32));
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Fundamental frequency must be >0.',BK);
            Erreur.identifier='SpecializedPowerSystems:MeanBlock:ParameterError';
            psberror(Erreur);
        end

        sps.Freq=Freq;
        sps.Vinit=Vinit;

        switch WantBlockChoice
        case 'Discrete';


            SamplesPerCycle=1./Freq/Ts;
            RoundSamplesPerCycle=ceil(SamplesPerCycle);
            sps.Delay=RoundSamplesPerCycle*Ts;
            Corr1=(SamplesPerCycle-RoundSamplesPerCycle)/2;
            Corr2=(SamplesPerCycle-RoundSamplesPerCycle)./SamplesPerCycle;
            sps.K1=Corr1.*Corr2;
            sps.K2=Corr2+Corr1.*Corr2;
        end
    end
