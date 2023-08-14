function h=update(h,ckttype,varargin)












    if~hasreference(h)
        setreference(h,rfdata.reference('CopyPropertyObj',false));
    end
    refobj=getreference(h);
    if hasreference(h)
        set(refobj,'IP3Data',[],'NFData',[],'MixerSpurData',[]);
    end


    switch upper(ckttype)
    case 'S-PARAMETERS'
        type=varargin{1};
        newNetData=varargin{2};
        newFreq=varargin{3};
        newZ0=varargin{4};


        update(refobj,type,newFreq,newNetData,newZ0,[],[],[],[],...
        [],[],[],[]);
        set(refobj,'OIP3',inf,'OneDBC',inf,'PS',inf,'GCS',inf);

    case 'NETWORK PARAMETERS'
        type=varargin{1};
        newNetData=varargin{2};
        newFreq=varargin{3};

        update(refobj,type,newFreq,newNetData,50,[],[],[],[],[],...
        [],[],[]);
        set(refobj,'OIP3',inf,'OneDBC',inf,'PS',inf,'GCS',inf);

    case 'PASSIVE'
        dataname='';
        newdata=varargin{1};
        netdata=[];
        noisedata=[];
        powerdata=[];
        oip3=inf;
        onedbc=inf;
        ps=inf;
        agcs=inf;
        if isa(newdata,'rfdata.data')
            newrefobj=getreference(newdata);
            if hasreference(newdata)
                netdata=get(newrefobj,'NetworkData');
                noisedata=get(newrefobj,'NoiseData');
                powerdata=get(newrefobj,'PowerData');
                dataname=get(newrefobj,'Name');
                oip3=get(newrefobj,'OIP3');
                onedbc=get(newrefobj,'OneDBC');
                ps=get(newrefobj,'PS');
                agcs=get(newrefobj,'GCS');
            end
        elseif isa(newdata,'rfdata.reference')
            newrefobj=newdata;
            netdata=get(newrefobj,'NetworkData');
            noisedata=get(newrefobj,'NoiseData');
            powerdata=get(newrefobj,'PowerData');
            dataname=get(newrefobj,'Name');
            oip3=get(newrefobj,'OIP3');
            onedbc=get(newrefobj,'OneDBC');
            ps=get(newrefobj,'PS');
            agcs=get(newrefobj,'GCS');
        elseif isa(newdata,'rfdata.network')
            netdata=newdata;
        else
            error(message(['rfblks:rfbbequiv:data:update:'...
            ,'WrongInputDataObject1']));
        end

        if~isa(netdata,'rfdata.network')&&isa(newdata,'rfdata.data')
            if~isempty(get(newdata,'Freq'))&&~isempty(get(newdata,...
                'S_Parameters'))
                netdata=rfdata.network('Type','S_PARAMETERS',...
                'Freq',get(newdata,'Freq'),...
                'Data',get(newdata,'S_Parameters'),...
                'Z0',get(newdata,'Z0'));
            elseif~isempty(get(newdata,'Freq'))&&...
                ~isempty(get(newdata,'Y_Parameters'))
                netdata=rfdata.network('Type','Y_PARAMETERS',...
                'Freq',get(newdata,'Freq'),...
                'Data',get(newdata,'Y_Parameters'),...
                'Z0',get(newdata,'Z0'));
            end
        end


        set(refobj,'NetworkData',netdata,'NoiseData',noisedata,...
        'PowerData',powerdata,'OIP3',oip3,'OneDBC',onedbc,...
        'PS',ps,'GCS',agcs);
        if~isempty(dataname)
            setname(refobj,dataname);
        end

    case 'AMPLIFIER'
        dataname='';
        newdata=varargin{1};
        netdata=[];
        noisedata=[];
        nfdata=[];
        powerdata=[];
        ip3data=[];
        oip3=inf;
        onedbc=inf;
        ps=inf;
        agcs=inf;
        if isa(newdata,'rfdata.data')
            newrefobj=getreference(newdata);
            if hasreference(newdata)
                netdata=get(newrefobj,'NetworkData');
                noisedata=get(newrefobj,'NoiseData');
                nfdata=get(newrefobj,'NFData');
                powerdata=get(newrefobj,'PowerData');
                ip3data=get(newrefobj,'IP3Data');
                dataname=get(newrefobj,'Name');
                oip3=get(newrefobj,'OIP3');
                onedbc=get(newrefobj,'OneDBC');
                ps=get(newrefobj,'PS');
                agcs=get(newrefobj,'GCS');
            end
        elseif isa(newdata,'rfdata.reference')
            newrefobj=newdata;
            netdata=get(newrefobj,'NetworkData');
            noisedata=get(newrefobj,'NoiseData');
            nfdata=get(newrefobj,'NFData');
            powerdata=get(newrefobj,'PowerData');
            ip3data=get(newrefobj,'IP3Data');
            dataname=get(newrefobj,'Name');
            oip3=get(newrefobj,'OIP3');
            onedbc=get(newrefobj,'OneDBC');
            ps=get(newrefobj,'PS');
            agcs=get(newrefobj,'GCS');
        elseif isa(newdata,'rfdata.network')
            netdata=newdata;
        elseif isa(newdata,'rfdata.power')
            powerdata=newdata;
        else
            error(message(['rfblks:rfbbequiv:data:update:'...
            ,'WrongInputDataObject2']));
        end

        if~isa(netdata,'rfdata.network')&&isa(newdata,'rfdata.data')
            if~isempty(get(newdata,'Freq'))&&...
                ~isempty(get(newdata,'S_Parameters'))
                netdata=rfdata.network('Type','S_PARAMETERS',...
                'Freq',get(newdata,'Freq'),...
                'Data',get(newdata,'S_Parameters'),...
                'Z0',get(newdata,'Z0'));
            elseif~isempty(get(newdata,'Freq'))&&...
                ~isempty(get(newdata,'Y_Parameters'))
                netdata=rfdata.network('Type','Y_PARAMETERS',...
                'Freq',get(newdata,'Freq'),...
                'Data',get(newdata,'Y_Parameters'),...
                'Z0',get(newdata,'Z0'));
            end
        end


        set(refobj,'NetworkData',netdata,'NoiseData',noisedata,...
        'NFData',nfdata,'PowerData',powerdata,...
        'IP3Data',ip3data,'OIP3',oip3,'OneDBC',onedbc,...
        'PS',ps,'GCS',agcs);
        if~isempty(dataname)
            setname(refobj,dataname);
        end
    end
    restore(h);
