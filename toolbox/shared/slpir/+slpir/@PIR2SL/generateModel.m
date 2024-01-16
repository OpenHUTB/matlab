function generateModel(this)
    showGeneratedModel=strcmp(this.ShowModel,'yes');
    hdldisp(message('hdlcoder:hdldisp:BeginModelgen'));

    hPir=this.hPir;

    if~validatePir(this,hPir)
        return;
    end

    this.createAndInitTargetModel;

    if this.nonTopDut
        generateOrigModel(this);

    end
    set_param(this.OutModelFile,'InheritedTsInSrcMsg','off');

    if this.needFullMdlGen
        removeForEachBlackBoxGenericComps(this,hPir);
        removeForIteratorBlackBoxes(this,hPir)

        this.preparePirForModelGen;

        if strcmpi(this.UseArrangeSystem,'yes')


            this.AutoPlace='no';
            this.AutoRoute='no';
        end

        if strcmpi(this.AutoPlace,'yes')
            try
                this.pirLayout=PirLayout(hPir,this.OutModelFile,this.ShowCodeGenPIR,this.SaveTemps);
                this.pirLayout.generateDotLayoutInfo;
            catch
                this.AutoPlace='no';
                warnObj=message('hdlcoder:engine:AutoPlaceFailed');
                this.reportCheck('Warning',warnObj);
            end
        end

        this.getUniqueEmlParamNum(true);

        this.startLayout;

        drawSLBlocks(this,hPir);

        fixTopLevelSubsystem(this);
    else

        copyDut(this);
    end

    if this.nonTopDut
        this.drawTest;
    else
        this.drawTestBench(false,true,true);
    end

    topN=this.hPir.getTopNetwork;
    if streamingmatrix.hasStreamedIOPorts(topN)&&~this.isDutWholeModel
        dutPath=[this.OutModelFilePrefix,this.RootNetworkName];
        obj=streamingmatrix.GeneratedModelHelper.getGMHelper(topN,dutPath);
        obj.drawGMInputOutputSubsystems;
    end

    finalizeModel(this);

    if showGeneratedModel
        openOutputModel(this);
    end
    hdldisp(message('hdlcoder:hdldisp:ModelgenComplete'));

    cleanupBE(this);

end


function removeForEachBlackBoxGenericComps(~,hPir)
    vNetworks=hPir.Networks;
    for i=1:length(vNetworks)
        hN=vNetworks(i);
        if~hN.Synthetic&&hN.isForEachSubsystem
            vComps=hN.Components;
            for j=1:length(vComps)
                hC=vComps(j);
                if hC.alwaysDraw
                    continue;
                elseif~hC.Synthetic&&...
                    hC.isBlackBox&&hC.elaborationHelper&&...
                    hC.hasGeneric&&hC.Owner.isForEachSubsystem
                    hN.removeComponent(hC);
                elseif hC.Owner.isForEachSubsystem&&hC.hasGeneric&&~hC.isBlackBox
                    hC.setShouldDraw(true);
                end
            end

        end
    end
end


function removeForIteratorBlackBoxes(~,hPir)

    ntwks=hPir.Networks;
    for i=1:numel(ntwks)
        hN=ntwks(i);
        if~hN.Synthetic&&hN.hasForIterDataTag
            fidt=hN.getForIterDataTag;

            if fidt.hasIterationCounter
                nonBBoxIC=fidt.getIterationCounter;
                nonBBoxIC.setShouldDraw(true);

                comps=hN.Components;
                for j=1:numel(comps)
                    hC=comps(j);

                    if hC.alwaysDraw
                        continue;

                    elseif~hC.Synthetic&&...
                        hC.isBlackBox&&hC.elaborationHelper&&...
                        strcmp(get_param(hC.OrigModelHandle,'BlockType'),'ForIterator')
                        hN.removeComponent(hC);


                        break;
                    end
                end
            end
        end
    end
end


function cleanupBE(this)
    this.pirLayout=[];
end


function openOutputModel(this)
    if this.DUTMdlRefHandle>0
        open_system(this.TopOutModelFile);
    else
        open_system(this.OutModelFile);
    end
end


function valid=validatePir(this,hPir)
    valid=1;

    if isempty(hPir.Networks)||isempty(hPir.getTopNetwork.Name)
        warnObj=message('hdlcoder:engine:invalidpir');
        warning(warnObj);
        reportCheck('Error',warnObj);

        valid=0;
        return;
    end

    ntwkName=hPir.getTopNetwork.Name;

    this.RootNetworkName=ntwkName;

    modelName=strtok(ntwkName,'/');
    searchInputMdl=find_system('type','block_diagram','name',modelName);

    if~isempty(searchInputMdl)
        this.SourceModelValid=1;
        cacheInputModelParams(this,modelName);
    end
end


function cacheInputModelParams(this,mdlName)

    try
        load_system(mdlName);

        if isempty(this.SolverName)
            this.SolverName=get_param(mdlName,'SolverName');

            if isempty(this.FixedStepSize)
                if strcmpi(this.SolverName,'FixedStepDiscrete')
                    this.FixedStepSize=get_param(mdlName,'FixedStep');
                end
            end
        end

        if(this.TotalRunTime==0.0)
            this.TotalRunTime=get_param(mdlName,'StopTime');
        end
    catch me
        error(message('hdlcoder:engine:unabletoopenmodel',mdlName));
    end
end


function fixTopLevelSubsystem(this)

    if isempty(this.InModelFile)
        return;
    end

    this.genmodeldisp('Fixing top level subsystem...',3);

    inDut=this.RootNetworkName;

    if strcmp(inDut,this.InModelFile)
        return;
    end

    outDut=regexprep(inDut,['^',this.InModelFile],this.OutModelFile);

    srcBlkh=get_param(inDut,'Handle');
    srcPos=get_param(srcBlkh,'Position');
    srcOrientation=get_param(srcBlkh,'Orientation');
    set_param(outDut,'Position',srcPos,'Orientation',srcOrientation);

    this.handleMaskParams(outDut,srcBlkh,[],false);
    atomicParam=get_param(outDut,'TreatAsAtomicUnit');
    if strcmp(atomicParam,'on')
        set_param(outDut,'SystemSampleTime','-1');
    end

end



function finalizeModel(this)
    rt=sfroot;
    src_machine=rt.find('-isa','Stateflow.Machine','Name',this.InModelFile);
    if~isempty(src_machine)
        src_target=src_machine.find('-isa','Stateflow.Target','Name','sfun');

        if~isempty(src_target)
            gm_machine=rt.find('-isa','Stateflow.Machine','Name',this.OutModelFile);

            if~isempty(gm_machine)
                gm_target=gm_machine.find('-isa','Stateflow.Target','Name','sfun');

                if~isempty(gm_target)
                    gm_machine.Debug.RunTimeCheck.StateInconsistencies=src_machine.Debug.RunTimeCheck.StateInconsistencies;
                    gm_machine.Debug.RunTimeCheck.DataRangeChecks=src_machine.Debug.RunTimeCheck.DataRangeChecks;
                    gm_machine.Debug.RunTimeCheck.CycleDetection=src_machine.Debug.RunTimeCheck.CycleDetection;
                    gm_machine.Debug.DisableAllBreakpoints=src_machine.Debug.DisableAllBreakpoints;
                    gm_machine.Debug.BreakOn.StateEntry=src_machine.Debug.BreakOn.StateEntry;
                    gm_machine.Debug.BreakOn.EventBroadcast=src_machine.Debug.BreakOn.EventBroadcast;
                    gm_machine.Debug.BreakOn.ChartEntry=src_machine.Debug.BreakOn.ChartEntry;
                    gm_machine.Debug.Animation.Delay=src_machine.Debug.Animation.Delay;
                    gm_machine.Debug.Animation.Enabled=src_machine.Debug.Animation.Enabled;
                    gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
                    gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
                    gm_target.CustomCode=src_target.CustomCode;
                    gm_target.CustomInitializer=src_target.CustomInitializer;
                    gm_target.CustomTerminator=src_target.CustomTerminator;
                    gm_target.UserIncludeDirs=src_target.UserIncludeDirs;
                    gm_target.UserLibraries=src_target.UserLibraries;
                    gm_target.UserSources=src_target.UserSources;
                    gm_target.setCodeFlag('debug',src_target.getCodeFlag('debug'));
                    gm_target.setCodeFlag('overflow',src_target.getCodeFlag('overflow'));
                end
            end
        end

    end
end


