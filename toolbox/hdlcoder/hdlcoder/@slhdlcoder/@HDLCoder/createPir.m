function numModels=createPir(this)







    level=1;
    numModels=this.markModelsForPirCreation(level);

    this.unpackProtectedModels;

    snn=this.getStartNodeName;

    if strcmp(hdlfeature('HDLBlockAsDUT'),'on')&&~strcmp(snn,bdroot(snn))...
        &&~this.getParameter('GenerateValidationModel')
        phan=get_param(snn,'PortHandles');
        ctrlist=[phan.Enable,phan.Reset,phan.Trigger];
        if~isempty(ctrlist)
            this.AllowBlockAsDUT=true;
        end
    end

    if~this.AllowBlockAsDUT
        checkIsValidStartNode(this,snn);
    end






    needToCompile=compileForMaskParams(this);

    if needToCompile
        this.mdlIdx=numModels;
        this.ModelConnection.initModel;



        if numel(this.AllModels)>1
            this.ModelConnection.termModel;
        end
    end








    sanityError=false;
    topModelState=[];
    for mdlIdx=1:numModels-1
        this.mdlIdx=mdlIdx;
        mdlName=this.AllModels(mdlIdx).modelName;
        oldState=this.initMakehdl(mdlName);
        if mdlIdx==1
            topModelState=oldState;
        end

        this.initIndustryStandardMode(mdlName,mdlName);
        slConnection=slhdlcoder.SimulinkConnection(mdlName);
        try
            [~,this.AllModels(mdlIdx).slFrontEnd]=this.createPirFrontEnd(slConnection,true);
        catch me
            slConnection.termModel;
            rethrow(me);
        end
        slConnection.termModel;
    end

    if strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')

        level=2;
        numModels=this.markModelsForPirCreation(level);
    end

    if~this.CalledFromMakehdl


        this.initMakehdl(this.ModelName);
        this.initIndustryStandardMode(this.ModelName,snn);
    end

    [~,this.AllModels(end).slFrontEnd]=this.createPirFrontEnd(this.ModelConnection,...
    this.isDutModelRef);


    this.initAllSubModels;

    for mdlIdx=1:numModels-1
        this.mdlIdx=mdlIdx;
        slFrontEnd=this.AllModels(mdlIdx).slFrontEnd;
        slConnection=slFrontEnd.SimulinkConnection;
        mdlName=slConnection.ModelName;
        try
            this.runPirFrontEnd(slFrontEnd,1);
        catch me
            slConnection.termModel;
            rethrow(me);
        end
        sanityChecks=this.pirSanityCheck(mdlIdx);
        if~isempty(sanityChecks)
            this.updateChecksCatalog(this.ModelName,sanityChecks);
            sanityError=true;
        end
    end


    this.mdlIdx=numModels;




    if this.CalledFromMakehdl
        if~isempty(topModelState)
            hdlcurrentdriver(topModelState.oldDriver)
        end
        this.loadConfigfiles(this.getConfigFiles,this.getStartNodeName);
    end


    nonTopDutComment='';
    if(this.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'off'))||this.isDutModelRef


        nonTopDutComment=get_param(get_param(this.DUTMdlRefHandle,'ActiveVariantBlock'),'Description');
    end

    this.runPirFrontEnd(this.AllModels(end).slFrontEnd,1);
    sanityChecks=this.pirSanityCheck(numModels);
    if~isempty(sanityChecks)

        this.updateChecksCatalog(this.ModelName,sanityChecks);
        sanityError=true;
    end
    if sanityError==true
        error(message('hdlcoder:engine:PIRConnectivityFailure',this.ModelName));
    end

    if~isempty(nonTopDutComment)
        addCommentOnNonTopDut(this,nonTopDutComment);
    end

    if~this.PirInstance.modifyRatesForSTI
        blockers=this.PirInstance.STIModificationBlockers;
        assert(~isempty(blockers));
        msg=message('hdlcoder:validate:ModelRefSampleTimeIndependent',blockers);
        this.AllModels(end).slFrontEnd.updateChecks(this.getStartNodeName,...
        'model',msg,'Error');
    end
    numModels=numel(this.AllModels);

end

function addCommentOnNonTopDut(this,nonTopDutComment)
    hThisNetwork=this.PirInstance.getTopNetwork;
    comment=hdlformatcomment(['Simulink subsystem description for ',hThisNetwork.Name,':']);
    hThisNetwork.addComment(comment);
    comment=hdlformatcomment(nonTopDutComment,2);
    hThisNetwork.addComment(comment);
end

function checkIsValidStartNode(this,snn)

    if strcmp(snn,bdroot(snn))
        return;
    end

    dut_blk_lib=hdlgetblocklibpath(snn);

    implDb=this.getImplDatabase();
    blocks=implDb.getSupportedBlocks();


    newblockLibPath={};
    for ii=1:length(blocks)
        blkLibPath=blocks{ii};
        if~strcmpi(blkLibPath,'built-in/SubSystem')&&...
            ~strcmpi(blkLibPath,'built-in/ModelReference')
            newblockLibPath{end+1}=blkLibPath;%#ok<AGROW>
        end
    end

    for ii=1:length(newblockLibPath)
        blkLibPath=newblockLibPath{ii};
        if strcmp(blkLibPath,dut_blk_lib)
            error(message('hdlcoder:engine:findstartnode'));
        end
    end

end





function needToCompile=compileForMaskParams(this)
    needToCompile=false;
    for mdlIdx=1:numel(this.AllModels)

        allMaskedSS=findActiveBlocks(this.getStartNodeName,'LookUnderMasks','all',...
        'FollowLinks','on','BlockType','SubSystem','Mask','on')';
        for maskSS=allMaskedSS
            maskInit=get_param(maskSS{:},'MaskInitialization');
            if~isempty(maskInit)
                needToCompile=true;
                return;
            end
        end
    end

end



