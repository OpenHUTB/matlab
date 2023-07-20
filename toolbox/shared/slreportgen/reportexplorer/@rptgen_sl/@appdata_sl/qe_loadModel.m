function modelName=qe_loadModel(adSL,modelName)


    adSL.reset;


    copyrightChar=char(169);
    returnChar=char(10);


    if nargin==0
        modelName='mf14';
    end


    ibm_encoding_alias={'ibm-5348_p100-1997','ibm-5348','windows-1252','cp1252'};


    encoding=slCharacterEncoding;
    if~any(strcmp(ibm_encoding_alias,encoding))
        bdclose('all');
        slCharacterEncoding('IBM-5348_P100-1997');
    end


    load_system(modelName);


    h=rptgen_sl.appdata_sl;
    adSL.CurrentModel=modelName;
    anno=find_system(modelName,'SearchDepth',1,'findall','on','type','annotation');
    if~isempty(anno)
        adSL.CurrentAnnotation=anno(1);
    end
    switch modelName
    case 'mf14'
        adSL.CurrentSystem=[adSL.CurrentModel,'/Controller ',copyrightChar];
        adSL.CurrentBlock=[adSL.CurrentSystem,'/Gain'];
    case 'msf_car'
        adSL.CurrentSystem=[adSL.CurrentModel,'/Engine'];
        adSL.CurrentBlock=[adSL.CurrentSystem,'/Sum'];
    case 'mvdp'
        adSL.CurrentSystem=[adSL.CurrentModel];
        adSL.CurrentBlock=[adSL.CurrentSystem,'/Mu'];
    case 'msf_boiler'
        adSL.CurrentSystem=[adSL.CurrentModel,'/Boiler',returnChar,'Plant model'];
        adSL.CurrentBlock=[adSL.CurrentSystem,'/digital',returnChar,'thermometer'];
    otherwise
        set_param(0,'CurrentSystem',modelName);
        adSL.CurrentSystem=gcs;
        adSL.CurrentBlock=gcb;
    end
    if~isempty(adSL.CurrentBlock)
        sig=getfield(get_param(adSL.CurrentBlock,'PortHandles'),'Outport');
        if~isempty(sig)
            adSL.CurrentSignal=sig;
        end
    end

