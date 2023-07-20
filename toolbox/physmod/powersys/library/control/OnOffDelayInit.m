function[WantBlockChoice,Ts,sps]=OnOffDelayInit(block,type_delay,delay,ic,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:OnOffDelayBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if~(delay>=Ts)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The Time delay must be >= One sample time.',BK);
            psberror(Erreur);
            return
        end

        if~all(ic==0|ic==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The previous input must be defined as either 0 or 1.',BK);
            psberror(Erreur);
            return
        end
    end


    if(min(delay)~=max(delay))
        sps.str=sprintf('multiple');
    else
        sps.str=sprintf('%g %c',delay(1),'s');
    end

    sps.type=type_delay;