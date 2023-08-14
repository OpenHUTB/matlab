function[sps]=THDInit(block,Freq,Ts)




    sps=[];

    [~,~,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init
        if any(Freq<=0)
            BK=strrep(block,char(10),char(32));
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Fundamental frequency must be >0.',BK);
            Erreur.identifier='SpecializedPowerSystems:THDBlock:ParameterError';
            psberror(Erreur);
        end
    end