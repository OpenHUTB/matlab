function h=analyze(h,~)








    models=get(h,'Models');
    if isempty(models)
        return
    end
    nmodels=get(h,'nModels');
    if(nmodels==0)
        return
    end


    for i=1:nmodels
        firstmodel=models{i};
        ckt=get(firstmodel,'RFckt');
        if isa(ckt,'rfckt.cascade')&&~isempty(get(ckt,'Ckts'))
            break;
        elseif isa(firstmodel,'rfbbequiv.nonlinear')&&...
            isnonlinear(firstmodel.RFckt)
            break;
        end
    end
    data=get(ckt,'AnalyzedResult');
    set(data,'Zs',get(h,'ZS'));
    if isa(ckt,'rfckt.cascade')&&numel(get(ckt,'Ckts'))==1&&...
        isa(ckt.Ckts{1},'rfbbequiv.ampinput')&&...
        isa(ckt.Ckts{1}.OriginalCkt,'rfckt.amplifier')&&...
        hasp2dreference(ckt.Ckts{1}.OriginalCkt.AnalyzedResult)
        ckt.Ckts{1}.OriginalCkt.AnalyzedResult.ZS=h.ZS;
    end

    lastmodel=models{nmodels};
    ckt=get(lastmodel,'RFckt');
    data=get(ckt,'AnalyzedResult');
    set(data,'ZL',get(h,'ZL'));
    if isa(ckt,'rfckt.cascade')&&numel(get(ckt,'Ckts'))==1&&...
        isa(ckt.Ckts{1},'rfbbequiv.ampoutput')&&...
        isa(ckt.Ckts{1}.OriginalCkt,'rfckt.amplifier')&&...
        hasp2dreference(ckt.Ckts{1}.OriginalCkt.AnalyzedResult)
        ckt.Ckts{1}.OriginalCkt.AnalyzedResult.ZL=h.ZL;
    end


    z0=findimpedance(h);
    if isa(h.OriginalCkt,'rfckt.cascade')
        set(h.OriginalCkt.AnalyzedResult,'Z0',z0,'Zs',get(h,'Zs'),...
        'Zl',get(h,'Zl'));
    end
    if nmodels==1
        z0=findimpedance(models{1});
        set(models{1}.RFckt.AnalyzedResult,'Z0',z0);
    else
        for k=1:nmodels
            model=models{k};
            if isa(model,'rfbbequiv.nonlinear')
                z0=findimpedance(model);
                if k>1
                    set(models{k-1}.RFckt.AnalyzedResult,'Z0',z0,'ZL',z0);
                end
                if k<nmodels
                    set(models{k+1}.RFckt.AnalyzedResult,'Z0',z0,'ZS',z0);
                end
            end
        end
    end



    freq=get(h,'InputFreq');
    if isempty(freq)
        freq=frequency(h);
    end


    fc=get(h,'Fc');
    f=freq;
    updatefrequency(h,freq);
    totalDelay=get(h,'ModelDelay');
    numLinModels=floor((nmodels+1)/2);
    maxLength=get(h,'MaxLength');

    for k=1:nmodels
        model=models{k};
        if isa(model,'rfbbequiv.nonlinear')
            set(model,'MaxLength',maxLength,...
            'FracBW',0,'ModelDelay',0,...
            'Fc',fc,'Ts',get(h,'Ts'),...
            'Seed',get(h,'Seed'),'NoiseFlag',get(h,'NoiseFlag'));
        else
            set(model,'MaxLength',maxLength,...
            'FracBW',get(h,'FracBW'),...
            'ModelDelay',totalDelay/numLinModels,'Fc',fc,...
            'Ts',get(h,'Ts'),'Seed',get(h,'Seed'),...
            'NoiseFlag',get(h,'NoiseFlag'));
        end
        analyze(model,f);
        if isa(model,'rfbbequiv.nonlinear')
            if~isempty(model.RFckt)&&isa(model.RFckt,'rfckt.mixer')&&...
                strcmp(model.RFckt.MixerType,'Downconverter')&&...
                (model.RFckt.FLO>fc)
                set(model,'InvertSignalSpectral',true);
            else
                set(model,'InvertSignalSpectral',false);
            end
        end
        fc=convertfreq(model,fc);
        f=convertfreq(model,f);
        if~isa(model,'rfbbequiv.nonlinear')

            systemdelay=totalDelay/numLinModels;
            if model.MaxLength<=systemdelay
                error(message(['rfblks:rfbbequiv:system:analyze:'...
                ,'ModelingDelayTooLarge'],totalDelay,model.MaxLength));
            end

            if~isempty(model.RFckt.AnalyzedResult.GroupDelay)
                systemdelay=systemdelay+...
                min(model.RFckt.AnalyzedResult.GroupDelay)/model.Ts;
            end
            if isa(model.RFckt,'rfckt.rfckt')&&...
                isa(model.RFckt.AnalyzedResult,'rfdata.data')&&...
                (model.MaxLength<=systemdelay)
                error(message(['rfblks:rfbbequiv:system:analyze:'...
                ,'FirFilterLengthTooSmall'],...
                model.MaxLength,ceil(systemdelay)));
            end
        end
    end


    model=models{1};
    resp=0.5*model.ImpulseResp;
    set(model,'ImpulseResp',resp);

    noise(h,freq);

    function noise(h,freq)
        nresp=[];
        ckt=h.OriginalCkt;

        if isa(ckt,'rfckt.cascade')&&strcmpi(get(h,'NoiseFlag'),'on')&&...
            ~isempty(ckt.Ckts)
            flags=setflagindexes(ckt);
            updateflag(ckt,flags.indexOfNoiseOn,1,flags.MaxNumberOfFlags);
            updateflag(ckt,flags.indexOfDoNonlinearAna,0,...
            flags.MaxNumberOfFlags);

            data=get(ckt,'AnalyzedResult');
            analyze(ckt,freq,data.Zl,data.Zs,data.Z0);


            ntransf=0;
            if isa(data,'rfdata.data')
                stransf=data.transfunc;
                if strcmpi(get(h,'NoiseFlag'),'on')
                    R=real(data.Zs);
                    K=rf.physconst('Boltzmann');
                    Ts=290;
                    NF=get(data,'NF');
                    F=10.^(NF/10);
                    B=1/get(h,'Ts');
                    Te=(F-1).*Ts;

                    Vout_square=4*K*Te*B*R;
                    ntransf=sqrt(Vout_square).*stransf(:);
                end
            end


            nresp=response(h,ntransf);
        end
        set(h,'NoiseResp',nresp);


        function updatefrequency(sys,freq)

            originalckt=sys.OriginalCkt;
            if isa(originalckt,'rfckt.cascade')
                ckts=originalckt.Ckts;
                f=freq;
                for j=1:length(ckts)
                    ckt=ckts{j};
                    set(ckt,'SimulationFreq',f);
                    f=convertfreq(ckt,f);
                    data=ckt.AnalyzedResult;
                    if~isa(data,'rfbbequiv.data')
                        data=rfbbequiv.data('CopyPropertyObj',false);
                    end
                    set(ckt,'DefaultFreq',data.Freq);
                end
                set(originalckt,'SimulationFreq',freq);
                data=originalckt.AnalyzedResult;
                if~isa(data,'rfbbequiv.data')
                    data=rfbbequiv.data('CopyPropertyObj',false);
                end
                set(originalckt,'DefaultFreq',data.Freq);
            end
