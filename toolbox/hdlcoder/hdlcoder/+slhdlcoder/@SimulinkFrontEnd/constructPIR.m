
function hThisNetwork=constructPIR(this,slName,configManager)


















    hPir=this.hPir;
    hThisNetwork=hPir.addNetwork;
    hThisNetwork.Name=slName;
    hThisNetwork.FullPath=slName;



    needToResethSS=false;
    hSS=get_param(slName,'Handle');
    if~isprop(get_param(hSS,'Object'),'BlockType')||...
        strcmp(get_param(slName,'BlockType'),'SubSystem')

        slbh=hSS;
    else



        slbh=slInternal('busDiagnostics','handleToExpandedSubsystem',hSS);
        needToResethSS=true;
    end
    hThisNetwork.SimulinkHandle=slbh;





    isMaskedSubsystem=any(hasmaskdlg(slbh))||any(hasmask(slbh)==2);
    hThisNetwork.setMaskedSubsystem(isMaskedSubsystem);



    if strcmp(slName,this.SimulinkConnection.System)
        modelName=strtok(slName,'/');
        desc=get_param(modelName,'Description');
        if~strcmp(desc,'')
            comment=hdlformatcomment(['Simulink model description for ',modelName,':']);
            hThisNetwork.addComment(comment);
            comment=hdlformatcomment(desc,2);
            hThisNetwork.addComment(comment);
        end
    end


    desc=get_param(slName,'Description');
    if~strcmp(desc,'')
        comment=hdlformatcomment(['Simulink subsystem description for ',slName,':']);
        hThisNetwork.addComment(comment);
        comment=hdlformatcomment(desc,2);
        hThisNetwork.addComment(comment);
    end

    this.checkBlock(slbh);

    compiledBlockList=getCompiledBlockList(get_param(slbh,'ObjectAPI_FP'));


    blocklist=this.resolveAndCheckIterationBlocks(compiledBlockList,hThisNetwork);

    blocklist=this.resolveSyntheticSubsystems(blocklist,this.SimulinkConnection.ModelName);


    blocklist=this.resolveSyntheticModelRefBlocks(blocklist);


    blocklist=this.pruneUnnecessaryNoHDLBlocks(blocklist);


    blocklist=this.resolveInactiveBlocks(blocklist);


    blockInfo=this.classifyblocks(blocklist);

    checkReferencedModelPorts(this,slbh,blockInfo);



    this.pirAddNetworkPorts(hThisNetwork,blockInfo,configManager);


    this.setSubsystemStateControl(blockInfo,hThisNetwork);


    this.blockInstantiation(slbh,blockInfo,configManager,hThisNetwork);



    this.setSubsystemParams(configManager,hThisNetwork);


    this.connectSignals(blocklist,hThisNetwork);



    checkSampleRateMatchForProtectedModels(this,blocklist,hThisNetwork);


    slhdlcoder.SimulinkFrontEnd.connectSynthBlocks(blockInfo.SyntheticBlocks,hThisNetwork);


    this.validateForEachPortTypes(hThisNetwork);


    annolist=find_system(slName,'findAll','on','SearchDepth','1',...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'LookUnderMasks','all','FollowLinks','on','Type','Annotation');
    this.annotationInstantiation(annolist,configManager,hThisNetwork);




    if needToResethSS
        hThisNetwork.SimulinkHandle=hSS;
    end
end




