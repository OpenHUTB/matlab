function[blockSampleColumnAsRow,...
    blockFrameBasedOutput,...
    blockInheritedLogging]=...
    analyzeModelForFrameUpgradeIssues(modelUnderTest)







    modelDir=[tempdir,'mymodelDir'];
    if~exist(modelDir,'dir')
        mkdir(modelDir)
    end
    pth=addpath(modelDir);

    modelUnderTestCopy=sprintf('%sCOPY',modelUnderTest);
    modelPath=which(modelUnderTest);

    [~,~,EXT]=fileparts(modelPath);
    copyfile(modelPath,fullfile(modelDir,[modelUnderTestCopy,EXT]),'f')


    targetReasons=getTragetUpdateReasons();


    debugStatus=sfc('coder_options','forceDebugOff');
    sfc('coder_options','forceDebugOff',1);


    evalc(sprintf('load_system(''%s'')',modelUnderTestCopy));



    evalc('report = ModelUpdater.update(modelUnderTestCopy, ''OperatingMode'',''Analyze'');');

    ind=[];
    for ii=1:length(targetReasons)
        ind=union(ind,find(ismember(report.blockReasons,targetReasons{ii})));
    end
    coveredBlocks=report.blockList(ind);


    LibBlockList={...
    'dspbuff3/Delay Line',...
    sprintf('dspobslib/Triggered\nDelay Line'),...
    'tic62dsplib/Autocorrelation',...
    'tic64dsplib/Autocorrelation'};


    CoreBlockList={'Inport','Outport','SignalSpecification'};


    libNames=getProductLibraries;



    already_visited_parents={};
    for ii=1:length(LibBlockList)
        blockReference=LibBlockList{ii};


        blocks=find_system(modelUnderTestCopy,...
        'LookInsideSubsystemReference','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on',...
        'FollowLinks','on',...
        'CaseSensitive','on',...
        'ReferenceBlock',blockReference);
        already_visited_parents=breakCustomLibraryLinks(already_visited_parents,blocks,coveredBlocks,modelUnderTestCopy,libNames);
    end


    for ii=1:length(CoreBlockList)
        blockType=CoreBlockList{ii};


        blocks=find_system(modelUnderTestCopy,...
        'LookInsideSubsystemReference','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','on',...
        'FollowLinks','on',...
        'CaseSensitive','on',...
        'BlockType',blockType);
        already_visited_parents=breakCustomLibraryLinks(already_visited_parents,blocks,coveredBlocks,modelUnderTestCopy,libNames);
    end



    evalc('report = ModelUpdater.update(modelUnderTestCopy, ''OperatingMode'',''Analyze'');');
    sfc('coder_options','forceDebugOff',debugStatus);


    blockSampleColumnAsRow=getUncoveredBlocks(report,targetReasons{1},...
    coveredBlocks,modelUnderTestCopy,modelUnderTest);

    blockFrameBasedOutput=getUncoveredBlocks(report,targetReasons{2},...
    coveredBlocks,modelUnderTestCopy,modelUnderTest);

    blockInheritedLogging=union(...
    getUncoveredBlocks(report,targetReasons{3},...
    coveredBlocks,modelUnderTestCopy,modelUnderTest),...
    getUncoveredBlocks(report,targetReasons{4},...
    coveredBlocks,modelUnderTestCopy,modelUnderTest));

    blockInheritedLogging=union(blockInheritedLogging,...
    getUncoveredBlocks(report,targetReasons{5},...
    coveredBlocks,modelUnderTestCopy,modelUnderTest));


    MATFileName=fullfile(modelDir,'vars_restore.mat');
    warnState=warning;
    warning('off');
    c=onCleanup(@()warning(warnState));

    old_variableNames=evalin('base','who');

    L=length(old_variableNames);
    variables_to_save={};
    for index=1:L
        isUpgradeObject=evalin('base',sprintf('isa(%s,''UpgradeAdvisor.Upgrader'')',old_variableNames{index}));
        if~isUpgradeObject
            variables_to_save{end+1}=old_variableNames{index};%#ok
        end
    end

    if~isempty(variables_to_save)
        save_str=sprintf('save(''%s''',MATFileName);
        for index=1:length(variables_to_save)
            save_str=sprintf('%s,''%s''',save_str,variables_to_save{index});
        end
        save_str=sprintf('%s)',save_str);
        try
            evalin('base',save_str);
        catch e %#ok
        end
        close_system(modelUnderTestCopy,0);
        new_variableNames=evalin('base','who');
        variables_to_be_restored=setdiff(variables_to_save,new_variableNames);
        try
            for index=1:length(variables_to_be_restored)
                load_str=sprintf('load(''%s'',''%s'')',MATFileName,variables_to_be_restored{index});
                evalin('base',load_str);
            end
        catch e %#ok
        end
        delete(MATFileName);
    else
        close_system(modelUnderTestCopy,0);
    end

    delete(fullfile(modelDir,[modelUnderTestCopy,EXT]));
    path(pth);
    [~]=rmdir(modelDir);


    function libNames=getProductLibraries




        libNames={'dspsrcs4','dspsnks4','dspadpt3','dspfdesign','dsparch4',...
        'dspmlti4','dspparest3','dspspect3','dsplp','dspxfrm3',...
        'dspstat3','dspquant2','dspsigops','dspmathops','dspmtrx3',...
        'dspfactors','dspinverses','dspsolvers','dsppolyfun',...
        'dspswit3','dspbuff3','dspindex','dspsigattribs',...
        'commrandsrc2','commseqgen2','commsink2',...
        'commsrccod2','commcrc2','commblkcod2','commblkintrlv2',...
        'commdigbbndam3','commdigbbndpm3','commdigbbndfm2',...
        'commdigbbndcpm2','commdigbbndtcm2','commofdm',...
        'commanapbnd3','commfilt2','commchan3','commrflib2',...
        'commrfcorlib','commsynccomp2','commtimrec2',...
        'commeq2','commmimo','commsequence2','commutil2','simulink'};


        function already_visited_parents=breakCustomLibraryLinks(already_visited_parents,blocks,coveredBlocks,modelUnderTestCopy,libNames)






            if~isempty(blocks)
                for kk=1:length(blocks)
                    if isempty(find(ismember(coveredBlocks,blocks{kk}),1))


                        blk=blocks{kk};
                        parent=get_param(blk,'Parent');

                        while(~strcmp(parent,modelUnderTestCopy))&&~any(strcmp(already_visited_parents,parent))
                            already_visited_parents{end+1}=parent;%#ok
                            if~isempty(find(ismember(coveredBlocks,parent),1))


                                break;
                            end
                            if~strcmp(get_param(parent,'LinkStatus'),'none')&&~strcmp(get_param(parent,'LinkStatus'),'implicit')


                                LibInf=libinfo(parent,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                                if~isempty(LibInf)
                                    libName=LibInf.Library;
                                end
                                doNotBreakLibLink=isempty(LibInf)||~isempty(find(ismember(libNames,libName),1));
                                if~doNotBreakLibLink
                                    set_param(parent,'LinkStatus','inactive');
                                end
                            end
                            parent=get_param(parent,'Parent');
                        end
                    end
                end
            end


            function blocks=getUncoveredBlocks(report,targetReason,coveredBlocks,modelUnderTestCopy,modelUnderTest)
                ind=find(ismember(report.blockReasons,targetReason));
                coveredBlocksNew=report.blockList(ind);
                blocks=setdiff(coveredBlocksNew,coveredBlocks);
                for ii=1:length(blocks)
                    blocks{ii}=strrep(blocks{ii},modelUnderTestCopy,modelUnderTest);
                end


                function targetReasons=getTragetUpdateReasons()


                    targetReasons={DAStudio.message('dsp:UpgradeAdvisor:TreatMby1Reason'),...
                    DAStudio.message('dsp:UpgradeAdvisor:SampleModeReason'),...
                    DAStudio.message('dsp:UpgradeAdvisor:Save2DReason'),...
                    DAStudio.message('Simulink:logLoadBlocks:UpAdvSave2dMode_SAVE_AS_2D_ReasonStr'),...
                    DAStudio.message('Simulink:logLoadBlocks:UpAdvSave2dMode_SAVE_AS_3D_ReasonStr')};
