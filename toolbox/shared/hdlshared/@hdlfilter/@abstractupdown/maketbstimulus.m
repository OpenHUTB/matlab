function inputdata=maketbstimulus(this,filterobj,varargin)

















    filterobj=createDfilt(this);
    [cando,errstr]=ishdlable(filterobj);
    if~cando
        error(message('HDLShared:hdlfilter:unsupportedarch',errstr));
    end


    hprop=PersistentHDLPropSet;
    if isempty(hprop),
        hprop=hdlcoderprops.HDLProps;
        PersistentHDLPropSet(hprop);
        hdlsetparameter('tbrefsignals',false);
    end
    set(hprop.CLI,varargin{:});
    updateINI(hprop);
    hINI=hprop.INI;
    hdl_parameters=hINI.getPropSet('TestBench').getPropSet('Common');
    stimparam=hdl_parameters.tb_stimulus;
    if isempty(stimparam)&&isempty(hdl_parameters.tb_user_stimulus),
        stimparam=defaulttbstimulus(filterobj);
    end

    slope=2;
    bias=1;
    chirpslope=1;
    chirpbias=0;

    if(isfir(filterobj)&&~isa(filterobj,'mfilt.cascade'))...
        ||issos(filterobj)
        ilen=impzlength(filterobj);
    else
        ilen=256;
    end

    zlen=ilen;

    range=[0:100];

    stimdata=[];

    if any(strcmpi('impulse',stimparam))
        impulse=zeros(1,ilen);
        impulse(1)=1.0;
        stimdata=[stimdata,impulse];
    end

    if any(strcmpi('step',stimparam))
        if~isempty(stimdata)
            stimdata=[stimdata,zeros(1,zlen)];
        end
        step=ones(1,ilen);
        step(1)=0;
        stimdata=[stimdata,step];
    end

    if any(strcmpi('ramp',stimparam))
        if~isempty(stimdata)
            stimdata=[stimdata,zeros(1,zlen)];
        end
        ramp=slope.*(range./range(end))-bias;
        stimdata=[stimdata,ramp];
    end

    if any(strcmpi('chirp',stimparam))
        if~isempty(stimdata)
            stimdata=[stimdata,zeros(1,zlen)];
        end
        chin=chirpslope.*chirp(range,0,range(end),0.49)+chirpbias;
        stimdata=[stimdata,chin];
    end


    if any(strcmpi('noise',stimparam))
        if~isempty(stimdata)
            stimdata=[stimdata,zeros(1,zlen)];
        end
        rnd=slope.*rand(1,range(end)+1)-bias;
        stimdata=[stimdata,rnd];
    end

    if~isempty(stimdata)
        stimdata=[stimdata,zeros(1,zlen)];


        if isa(filterobj,'mfilt.abstractmultirate')||...
            isa(filterobj,'mfilt.cascade')
            rcf=getratechangefactors(filterobj);
            if all(rcf(:,1)==1)
                stimlen=length(stimdata);
                stimmod=mod(stimlen,prod(rcf(:,2)));
                if stimmod~=0
                    stimdata=[stimdata,zeros(1,(prod(rcf(:,2))-stimmod))];
                end
            end
        end
    end

    if~isempty(hdl_parameters.tb_user_stimulus)
        if~isempty(stimdata)
            stimdata=[stimdata,zeros(1,zlen)];
        end
        userdata=hdl_parameters.tb_user_stimulus;
        if size(userdata,1)>1
            userdata=userdata.';
        end
        stimdata=[stimdata,userdata];
    end

    if isempty(stimdata)
        error(message('HDLShared:hdlfilter:unknownstimulus'));
    end

    if isa(filterobj,'dfilt.cascade')
        tmpfilt=filterobj.Stage(1);
    else
        tmpfilt=filterobj;
    end

    switch tmpfilt.arithmetic
    case 'double'
        stimdata=double(stimdata);
    case 'fixed'
        stimdata=fi(stimdata,true,...
        tmpfilt.InputWordLength,tmpfilt.InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end

    if nargout==0
        stimdata=double(stimdata);

        nstims=length(stimparam);

        if~isempty(hdl_parameters.tb_user_stimulus)
            if nstims==1
                stimname='stimulus';
                stims=sprintf('%s ',stimparam{:});
            else
                stimname='stimuli';
                stims=sprintf('%s, ',stimparam{:});
            end
            if isempty(stims)
                stims='user defined';
                stimname='stimulus';
            else
                stims=[stims,'and user defined'];
                stimname='stimuli';
            end
        else
            if nstims==1
                stimname='stimulus';
                stims=sprintf('%s ',stimparam{:});
            elseif nstims==2
                stimname='stimuli';
                stims=sprintf('%s and %s ',stimparam{:});
            else
                stimname='stimuli';
                stims=sprintf('%s, ',stimparam{:});
            end
            if stims(end-1:end)==', '
                stims=stims(1:end-2);
            else
                stims=stims(1:end-1);
            end
            lastcomma=find(stims==',');
            if~isempty(lastcomma)
                stims=[stims(1:lastcomma(end)),' and',stims(lastcomma(end)+1:end)];
            end
        end


        hdl=plot(stimdata);
        ylim(ylim.*1.1);
        title(sprintf('Stimulus data for filter %s\nwith %s %s.',...
        inputname(1),stims,stimname),...
        'Interpreter','none');

    else
        inputdata=stimdata;
    end


