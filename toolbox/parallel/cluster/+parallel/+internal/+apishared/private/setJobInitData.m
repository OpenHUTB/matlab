function setJobInitData(~,data)













    try
        KEY_LENGTH=100;

        key=data(1:KEY_LENGTH);
        cypherText=data(KEY_LENGTH+1:end);

        numelPlainText=numel(cypherText);
        plainText=zeros(1,numelPlainText,'uint8');

        for i=1:KEY_LENGTH:numelPlainText
            textStart=i;
            textEnd=min(numelPlainText,textStart+KEY_LENGTH-1);
            keyStart=1;
            keyEnd=textEnd-textStart+1;
            plainText(textStart:textEnd)=bitxor(cypherText(textStart:textEnd),key(keyStart:keyEnd));
        end

        initData=distcompdeserialize(plainText);
        [clientIsDeployed,sessionKey,publicKey,clientSector,clientProductList]=initData{:};

        if clientIsDeployed&&~isdeployed()







            parallel.internal.general.excludeCwdFromPath();
            dctSchedulerMessage(4,'Client is deployed.');
        end


        parallel.internal.lmgr.clearFeatures();

        iCheckSector(clientSector)

        pctSetmcrappkeys(sessionKey,publicKey);

        parallel.internal.lmgr.addFeatures(clientProductList);




        builtin('license','checkout','distrib_computing_toolbox');
    catch err
        if strcmp(err.identifier,'parallel:cluster:SectorLicenseError')
            rethrow(err);
        else
            newErr=MException(message('parallel:cluster:CannotSetLicenseInfo'));
            throw(newErr.addCause(err));
        end
    end

    function iCheckSector(clientSector)
















































        workerSector=builtin('_pctLicenseType');

        UNKN=0;
        TRIAL=100;
        COMM=300;
        SPONSOR_3RD_PARTY=230;
        THIRD_PARTY=320;

        if(clientSector==COMM&&~ismember(workerSector,[UNKN,TRIAL,COMM]))||...
            (clientSector==SPONSOR_3RD_PARTY&&workerSector~=SPONSOR_3RD_PARTY)||...
            (workerSector==SPONSOR_3RD_PARTY&&clientSector~=SPONSOR_3RD_PARTY)||...
            (clientSector==THIRD_PARTY&&workerSector~=THIRD_PARTY)||...
            (workerSector==THIRD_PARTY&&clientSector~=THIRD_PARTY)
            parallel.internal.lmgr.clearFeatures();

            parallel.internal.lmgr.addFeatures("Distrib_Computing_Toolbox");
            error(message('parallel:cluster:SectorLicenseError',clientSector,workerSector));
        end

        getSetSector(clientSector);
