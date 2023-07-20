function[WantBlockChoice,Ts,sps]=PLLInit(block,Fmin,Par_Init,ParK,TcD,MaxRateChangeFreq,FilterCutOffFreq,AGC,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);


    if Init

        Erreur.identifier='SpecializedPowerSystems:PLLBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if Fmin<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The minimum frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if FilterCutOffFreq<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The filter cut-off frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if MaxRateChangeFreq<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The maximum rate of change of frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if length(Par_Init)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The size of  the "Initial input" parameter must be 2.',BK);
            psberror(Erreur);
            return
        end

        if length(ParK)~=2&&length(ParK)~=3
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The size of  the "Regulator gains" parameter must be 2 (Kp Ki)  or 3 (Kp Ki Kd).',BK);
            psberror(Erreur);
            return
        end


        if Ts>0

            if TcD<Ts


                Erreur.message=sprintf('Parameter error in the ''%s'' block: The time constant for derivative action (%s) must be higher or equal to the block sample time (%s).',BK,TcD,Ts);
                psberror(Erreur);
                return
            end
        end



        sps.Fmin=Fmin;
        sps.Kp=ParK(1);
        sps.Ki=ParK(2);
        if length(ParK)==2
            sps.Kd=0;
        else
            sps.Kd=ParK(3);
        end
        sps.TcD=TcD;
        sps.Phase_Init=Par_Init(1);
        sps.Finit=Par_Init(2);
        sps.MaxRateChangeFreq=MaxRateChangeFreq;
        sps.FilterCutOffFreq=FilterCutOffFreq;
        sps.AGC=AGC;

    end