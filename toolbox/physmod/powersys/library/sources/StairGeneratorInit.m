function[WantBlockChoice,Ts,sps]=StairGeneratorInit(block,Time,Amplitude,Ts)




    sps=[];

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);
    StartTime=eval(get_param(bdroot,'StartTime'),'0');



    if Init

        Erreur.identifier='SpecializedPowerSystems:StairGeneratorBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Time<StartTime)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: Transition times must be >= StartTime (%g sec)',BK,StartTime);
            psberror(Erreur);
            return
        end

        if length(Amplitude)~=length(Time)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The vectors specifying the time and amplitude pairs must have the same length.',BK);
            psberror(Erreur);
            return
        end

        n=length(Time);
        vec_dt=[Time,0]-[min(Time)-1,Time];
        vec_dt=vec_dt(2:n);
        if any(vec_dt<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: All transition times must be in increasing order.',BK);
            psberror(Erreur);
            return
        end

    end


    if Time(1)~=StartTime
        Time=[StartTime,Time];
        Amplitude=[0,Amplitude];
    end



    if Ts>0
        Time(2:end)=Time(2:end)-Ts+eps(Time(2:end));
    end

    sps.tv=[Time(1),reshape(repmat(reshape(Time(2:end),1,length(Time)-1),2,1),1,2*length(Time)-2),Time(end)+1];
    sps.opv=[reshape(repmat(Amplitude(1:end-1),2,1),1,2*length(Amplitude)-2),Amplitude(end),Amplitude(end)];







    sps.tv_block=sps.tv(1:2:length(sps.tv));
    sps.opv_block=sps.opv(1:2:length(sps.opv));






    if length(sps.tv_block)==1&&sps.tv_block==0
        sps.tv_block=[sps.tv_block,eps];
        sps.opv_block=[sps.opv_block,sps.opv_block];
    end
