function[WantBlockChoice,Ts,sps]=PositiveSequencePLLDrivenInit(block,Finit,Fmin,Par_Init,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:PositiveSequencePLLDrivenBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Finit<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Initial frequency must be >0.',BK);
            psberror(Erreur);
            return
        end
        if any(Fmin<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Minimum frequency must be >0.',BK);
            psberror(Erreur);
            return
        end
        if length(Par_Init)~=2
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the "Initial input" parameter must be 2.',BK);
            psberror(Erreur);
            return
        end

        sps.Finit=Finit;
        sps.Fmin=Fmin;
        sps.Real_Init=Par_Init(:,1)*cos(pi/180*Par_Init(:,2));
        sps.Imag_Init=Par_Init(:,1)*sin(pi/180*Par_Init(:,2));

    end