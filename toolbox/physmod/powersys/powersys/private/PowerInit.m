function[WantBlockChoice,Ts,sps]=PowerInit(block,Freq,Par_Vinit,Par_Iinit,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:PowerBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Freq<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Fundamental frequency must be >0.',BK);
            psberror(Erreur);
            return
        end
        if size(Par_Vinit,2)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of columns of the "Voltage initial input" matrix must be 2.',BK);
            psberror(Erreur);
            return
        end
        if size(Par_Iinit,2)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of columns of the "Current initial input" matrix must be 2.',BK);
            psberror(Erreur);
            return
        end


        sps.Freq=Freq;
        sps.Par_Vinit=Par_Vinit;
        sps.Par_Iinit=Par_Iinit;

    end