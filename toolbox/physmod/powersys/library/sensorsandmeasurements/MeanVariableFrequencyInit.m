function[WantBlockChoice,Ts,sps]=MeanVariableFrequencyInit(block,Finit,Fmin,Vinit,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:MeanVariableFrequencyBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Finit<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Initial frequency must be >0.',BK);
            psberror(Erreur);
        end
        if any(Fmin<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Minimum frequency must be >0.',BK);
            psberror(Erreur);
        end

        sps.Finit=Finit;
        sps.Fmin=Fmin;
        sps.Vinit=Vinit;

    end