function[sps]=RMSInit(block,Freq,Par_Init,TrueRMS_On,Ts)




    sps.TrueRMS_On=TrueRMS_On;
    if TrueRMS_On==1
        sps.PortName='TrueRMS';
    else
        sps.PortName='RMS';
    end

    [~,~,~,Init]=DetermineBlockChoice(block,Ts,0,0);

    if Init

        if any(Freq<=0)
            BK=strrep(block,char(10),char(32));
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Fundamental frequency must be >0.',BK);
            Erreur.identifier='SpecializedPowerSystems:RMSBlock:ParameterError';
            psberror(Erreur);
            return
        end


        sps.Freq=Freq;

        sps.Par_Init_TrueRMS=Par_Init.*Par_Init;
        sps.Par_Init_RMS=cat(2,(Par_Init.*sqrt(2))',zeros(1,length(Par_Init))');

    end