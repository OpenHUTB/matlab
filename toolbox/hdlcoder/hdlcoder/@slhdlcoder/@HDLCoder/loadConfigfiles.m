function loadConfigfiles(this,files,snn)


    if nargin<3
        snn=this.getStartNodeName;
    end

    if nargin<2
        files=this.getConfigFiles;
    end

    if isempty(snn)
        mdlName=this.ModelName;
    else
        mdlName=strtok(snn,'/');
    end

    configMgr=this.getConfigManager(mdlName);


    configMgr.parseConfiguration(this.ImplDB,snn,files);

    if isempty(files)||isempty(configMgr.MergedConfigContainer)
        return;
    end

    hdlTop=configMgr.MergedConfigContainer.HDLTopLevel;


    if this.DUTMdlRefHandle>0&&strcmp(hdlTop(3:end),mdlName)


        hdlTop=hdlTop(3:end);
    else
        hdlTop=regexprep(hdlTop,'^\.',mdlName);
    end

    configMgr.MergedConfigContainer.HDLTopLevel=hdlTop;
    if~isempty(hdlTop)



        [t,r]=strtok(configMgr.MergedConfigContainer.HDLTopLevel,'/');




        if isempty(r)||...
            strcmp(t,mdlName)


            this.updateStartNodeName(hdlTop);
        end
    end

    paramSettings=configMgr.MergedConfigContainer.settings;
    if~isempty(paramSettings)
        this.updateParams(paramSettings);
    end
