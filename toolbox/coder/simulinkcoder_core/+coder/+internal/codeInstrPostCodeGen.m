function codeInstrPostCodeGen(...
    lXilInfo,...
    lTargetType,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lTopOfBuildModel,model,buildInfoInstr,buildInfoOriginal,...
    lRelativePathToAnchor,...
    lAnchorFolder,...
    isIDELinkTarget,...
    instrumentationThisModelUpToDate,...
    componentRegistryIn,...
    lCodeGenerationId,...
    lInstrObjFolder,...
    lBuildDirectory,...
    lCodeInstrInfo,...
    codeInstrEnabled,...
    refModelsWithProfiling)






    profilingInfoFile=fullfile(lBuildDirectory,lInstrObjFolder,'profiling_info.mat');

    [lTopLevelRegistryStored,lComponentRegistriesStored,lGlobalRegistryStored]=...
    i_getProfInfoStored(profilingInfoFile);

    lTopLevelRegistryNew=[];
    lGlobalRegistryNew=[];


    lComponentRegistriesUpdated=i_getUpdatedComponentRegistries...
    (componentRegistryIn,codeInstrEnabled,lComponentRegistriesStored);


    processTopModelCodeProfiling=...
    (lCodeExecutionProfilingTop||lCodeStackProfilingTop)&&...
    strcmp(lTargetType,'NONE')&&...
    strcmp(lTopOfBuildModel,model);

    if processTopModelCodeProfiling


        if isempty(buildInfoOriginal.ModelRefs)
            componentPaths={};
        else
            componentPaths={buildInfoOriginal.ModelRefs.Path};
            componentPaths=...
            regexprep(componentPaths,'\$\(START_DIR\)(\/|\\)','','once');
        end

        if~instrumentationThisModelUpToDate||isempty(lGlobalRegistryNew)

            lGlobalRegistryNew=coder.profile.ProbeGlobalRegistry...
            (model,lAnchorFolder,lRelativePathToAnchor);

            if~lXilInfo.IsSilAndPws
i_insertTopLevelInstrumentation...
                (model,buildInfoInstr,lGlobalRegistryNew);
            end

            [~,lTopLevelRegistryNew]=lGlobalRegistryNew.getRegistryInfo;
            if~isempty(lTopLevelRegistryNew)
                lTopLevelRegistryNew=lTopLevelRegistryNew{1};
            end


            componentRegistries=coder.internal.getInstrRegistriesForRefModels...
            (componentPaths,lCodeInstrInfo,lAnchorFolder,refModelsWithProfiling);
            lGlobalRegistryNew.addRegistries([componentRegistries,lComponentRegistriesUpdated]);
        else


            lGlobalRegistryNew=i_createGlobalRegistry...
            (lGlobalRegistryStored,...
            componentPaths,...
            lTopLevelRegistryStored,...
            lComponentRegistriesUpdated,...
            model,lAnchorFolder,...
            lRelativePathToAnchor,...
            lCodeInstrInfo,...
            refModelsWithProfiling);
        end

        if isempty(lGlobalRegistryStored)
            lGlobalRegistryUpToDate=false;
        else
            checksumStored=lGlobalRegistryStored.getModelInstrumentationChecksum;
            lGlobalRegistryUpToDate=~isempty(checksumStored)...
            &&isequal(checksumStored,...
            lGlobalRegistryNew.getModelInstrumentationChecksum);
        end


        writeUtilityFunctions=~lGlobalRegistryUpToDate||~instrumentationThisModelUpToDate;
i_writeAndRegisterUtilityFcns...
        (writeUtilityFunctions,lGlobalRegistryNew,lXilInfo,...
        isIDELinkTarget,buildInfoInstr,model,...
        get_param(model,'TargetWordSize'),...
        8);


    else
        lGlobalRegistryUpToDate=true;
    end

    if~instrumentationThisModelUpToDate||~lGlobalRegistryUpToDate

        if~isempty(lTopLevelRegistryNew)
            lTopLevelRegistry=lTopLevelRegistryNew;
        else
            lTopLevelRegistry=lTopLevelRegistryStored;
        end

        if~isempty(lGlobalRegistryNew)
            lGlobalRegistry=lGlobalRegistryNew;
        else
            lGlobalRegistry=lGlobalRegistryStored;
        end

        profInfo=struct(...
        'lGlobalRegistry',{lGlobalRegistry},...
        'componentRegistries',{lComponentRegistriesUpdated},...
        'topLevelRegistry',{lTopLevelRegistry},...
        'codeGenerationId',{lCodeGenerationId}...
        );

        i_saveProfInfo(profInfo,profilingInfoFile);
    end

    if get_param(model,'TargetBitPerInt')<64&&...
        get_param(model,'TargetBitPerLong')<64&&...
        (strcmp(get_param(model,'TargetLongLongMode'),'off')||...
        get_param(model,'TargetBitPerLongLong')<64)
        buildInfoInstr.addDefines('PROFILING_DEFINE_UINT64_TIMER_TYPE','OPTS');
    end


    function lGlobalRegistry=i_createGlobalRegistry...
        (globalRegistry,componentPaths,...
        topLevelRegistry,componentRegistries,...
        model,lAnchorFolder,lRelativePathToAnchor,...
        lCodeInstrInfo,refModelsWithProfiling)

        assert(~isempty(globalRegistry),'Saved global registry must not be empty');

        lGlobalRegistry=coder.profile.ProbeGlobalRegistry...
        (model,lAnchorFolder,lRelativePathToAnchor);
        lGlobalRegistry.ProfilingTimer=globalRegistry.ProfilingTimer;
        lGlobalRegistry.TargetCollectDataFcnName=globalRegistry.TargetCollectDataFcnName;

        lGlobalRegistry.SourceFileTargetInterface=...
        globalRegistry.SourceFileTargetInterface;
        lGlobalRegistry.HeaderFileTargetInterface=...
        globalRegistry.HeaderFileTargetInterface;
        lGlobalRegistry.SingleThreadTiming=...
        globalRegistry.SingleThreadTiming;
        modelRefRegistries=coder.internal.getInstrRegistriesForRefModels...
        (componentPaths,lCodeInstrInfo,lAnchorFolder,refModelsWithProfiling);
        lGlobalRegistry.addRegistries...
        ([modelRefRegistries...
        ,{topLevelRegistry}...
        ,componentRegistries]);

        function i_writeAndRegisterUtilityFcns...
            (writeUtilityFunctions,lGlobalRegistry,lXilInfo,isIDELinkTarget,...
            buildInfoInstr,model,targetWordSize,targetBitPerChar)

            [~,allRegistries]=lGlobalRegistry.getRegistryInfo;



            lIsSilAndPws=lXilInfo.IsSilAndPws;




            ideLinkSpecial=isIDELinkTarget&&(lXilInfo.IsPilBlock||lXilInfo.IsTopModelPil);

            needProfilingUtils=~isempty(allRegistries)...
            &&lGlobalRegistry.getTotalNumberOfProbes>0...
            &&~ideLinkSpecial...
            &&~lIsSilAndPws;


            if needProfilingUtils
                if lGlobalRegistry.RequireXCPSupport&&~lGlobalRegistry.UploadDataInRealTime
                    lGlobalRegistry.updateNumberOfTimeProbes;
                    lCaptureRegistry=coder.profile.CaptureProbeComponentRegistry(...
                    model,'',targetWordSize,[],fileparts(lGlobalRegistry.XCPInstrumentedFolder));
                    lGlobalRegistry.addRegistries({lCaptureRegistry});
                    lCaptureRegistry.requestCaptureProbes(lGlobalRegistry.TotalTimeProbe);
                end
                if writeUtilityFunctions


                    lGlobalRegistry.writeTargetInterface(targetWordSize);
                end




                lTimer=lGlobalRegistry.ProfilingTimer;
                addSources=true;
                srcFileTargetInterface={lGlobalRegistry.SourceFileTargetInterface};
                hdrFileTargetInterface={lGlobalRegistry.HeaderFileTargetInterface};
                if lGlobalRegistry.RequireXCPSupport
                    [~,~,srcExt]=fileparts(lGlobalRegistry.SourceFileTargetInterface);
                    [~,~,hdrExt]=fileparts(lGlobalRegistry.HeaderFileTargetInterface);
                    srcFileTargetInterface{2}=fullfile(lGlobalRegistry.XCPInstrumentedFolder,lGlobalRegistry.getXCPMainSourceFile(srcExt));
                    hdrFileTargetInterface{2}=fullfile(lGlobalRegistry.XCPInstrumentedFolder,lGlobalRegistry.getXCPMainHeaderFile(hdrExt));
                    for i=1:length(lGlobalRegistry.AddXCPSourceFiles)
                        srcFileTargetInterface{end+1}=lGlobalRegistry.AddXCPSourceFiles{i};%#ok<AGROW>
                    end
                    for i=1:length(lGlobalRegistry.AddXCPHeaderFiles)
                        hdrFileTargetInterface{end+1}=lGlobalRegistry.AddXCPHeaderFiles{i};%#ok<AGROW>
                    end
                    i_writeXCPProfilingInfo(lGlobalRegistry,targetWordSize,targetBitPerChar);
                end
                coder.internal.buildInfoTimerUpdate...
                (buildInfoInstr,lTimer,srcFileTargetInterface,hdrFileTargetInterface,addSources);
            end

            function i_writeXCPProfilingInfo(lGlobalRegistry,targetWordSize,targetBitPerChar)


                model=lGlobalRegistry.Model;

                targetInfo.summaryOnly=~strcmp(get_param(model,'CodeProfilingSaveOptions'),'AllData');
                targetInfo.onTargetOnly=~lGlobalRegistry.UploadDataInRealTime;
                lTimerType=lGlobalRegistry.ProfilingTimer.getTimerType;
                targetInfo.timerTypeMaxValue=intmax(lTimerType);
                identifierMaxVal=coder.profile.ExecTimeConfig...
                .getIdentifierMaxValueFromTargetWordSize(targetWordSize);
                targetInfo.identifierMaxVal=identifierMaxVal;
                timerInBytes=rtw.connectivity.TypeUtils.builtinHostByteSize(lTimerType);
                targetInfo.timerInBytes=uint8(timerInBytes);
                targetInfo.timerTypeName=lTimerType;
                tps=lGlobalRegistry.ProfilingTimer.getTicksPerSecond;
                if isempty(tps)
                    tps=0;
                end
                targetInfo.ticksPerSecond=uint64(tps);
                if~isempty(lGlobalRegistry.TimerHWCounterUnit)
                    targetInfo.TimerHWCounterUnit=lGlobalRegistry.TimerHWCounterUnit;
                end
                lWordSizeInBytes=targetWordSize/targetBitPerChar;
                targetInfo.wordSizeInBytes=uint8(lWordSizeInBytes);
                targetInfo.eventID=lGlobalRegistry.XCPEventID;
                lIsMultiTasking=~lGlobalRegistry.SingleTaskModel;
                lHasNodeID=~isempty(lGlobalRegistry.XCPCoreIDFcn);
                lHasThreadID=~isempty(lGlobalRegistry.XCPThreadIDFcn);
                targetInfo.hasNodeField=logical(lIsMultiTasking&&lHasNodeID);
                targetInfo.hasThreadField=logical(lIsMultiTasking&&lHasThreadID);
                targetInfo.bufferName=lGlobalRegistry.XCPBufferConfig.BufferName;
                targetInfo.numSamples=uint32(lGlobalRegistry.XCPBufferConfig.NumSamples);
                targetInfo.isXCPTarget=true;
                targetInfo.expectedBufferSize=lGlobalRegistry.XCPBufferConfig.BufferSizeInBytes;

                taskSectionIds=lGlobalRegistry.getTaskInfo(coder_profile_ProbeType.TASK_TIME_PROBE);
                targetInfo.taskSectionIds=uint32(taskSectionIds);
                targetInfo.taskPriorities=uint32(40-taskSectionIds);
                targetInfo.numCores=uint32(lGlobalRegistry.XCPNumCores);
                targetInfo.modelName=model;

                info.targetInfo=targetInfo;

                mainDir=lGlobalRegistry.XCPInstrumentedFolder;

                coder.profile.CoderInstrumentationInfo.writeInfo(fileparts(mainDir),info);

                function profInfo=i_saveProfInfo(profInfo,profilingInfoFile)

                    save(profilingInfoFile,'-struct','profInfo');

                    function[lTopLevelRegistry,lComponentRegistries,lGlobalRegistry]=...
                        i_getProfInfoStored(profilingInfoFile)


                        if exist(profilingInfoFile,'file')
                            profInfo=load(profilingInfoFile);
                            fieldNames=fieldnames(profInfo);
                            assert(isequal(sort(fieldNames),{
'codeGenerationId'
'componentRegistries'
'lGlobalRegistry'
                            'topLevelRegistry'}));
                            lTopLevelRegistry=profInfo.topLevelRegistry;
                            lComponentRegistries=profInfo.componentRegistries;
                            lGlobalRegistry=profInfo.lGlobalRegistry;
                        else
                            lTopLevelRegistry=[];
                            lGlobalRegistry=[];
                            lComponentRegistries={};
                        end

                        function updatedComponentRegistries=i_getUpdatedComponentRegistries...
                            (componentRegistryIn,codeInstrEnabled,lComponentRegistriesStored)


                            keepIdx=true(size(lComponentRegistriesStored));
                            if(~isempty(componentRegistryIn)||~codeInstrEnabled)

                                for ii=1:length(keepIdx)



                                    if~isa(lComponentRegistriesStored{ii},'SlCov.coder.CodeCovProbeComponentRegistry')
                                        keepIdx(ii)=false;
                                    end
                                end
                            end

                            updatedComponentRegistries=lComponentRegistriesStored(keepIdx);

                            if~isempty(componentRegistryIn)

                                updatedComponentRegistries{end+1}=componentRegistryIn;
                            end



                            function i_insertTopLevelInstrumentation(model,buildInfoInstr,lGlobalRegistryTemp)


                                callbackFcn=get_param(model,'ExecTimeCallbackPrm');
                                feval(callbackFcn,...
                                model,...
                                lGlobalRegistryTemp,...
                                buildInfoInstr);
