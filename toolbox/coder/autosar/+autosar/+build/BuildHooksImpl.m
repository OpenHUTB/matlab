classdef BuildHooksImpl<handle




    methods(Static)

        function error(modelName,varargin)





            msg=DAStudio.message('RTW:makertw:buildAborted',modelName);
            disp(msg);
        end

        function entry(modelName,varargin)



            msg=DAStudio.message('RTW:makertw:enterRTWBuild',modelName);
            disp(msg);

            coder.internal.xrel.AUTOSAR.AutosarExternalCodeImportHook.entryHook(modelName);

            if autosar.build.BuildHooksImpl.isStandaloneBuild(modelName)
                if~autosarcore.isValidAutosarBuild(modelName)&&~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                    DAStudio.error('RTW:autosar:buildError');
                else
                    [app2impMap,~,mode2ImpMap]=autosar.api.Utils.app2ImpMap(modelName);
                    implTypes=unique([app2impMap.values,mode2ImpMap.values]);

                    if(~isempty(implTypes))





                        repTypes=ec_get_replacetype_mapping_list(modelName);
                        implTypes=setdiff(implTypes,repTypes);
                        rtwprivate('reserveIdentifier',modelName,implTypes);
                    end
                end


                autosar.mm.util.validateModel(modelName,'init');


                autosar.simulink.bep.Mapping.syncDictionary(modelName);


                autosar.simulink.functionPorts.DictionarySyncer.sync(modelName);



                autosar.blocks.InternalTriggerBlock.syncMapping(modelName);
            elseif strcmp(get_param(modelName,'ModelReferenceTargetType'),'RTW')




                intTrigBlocks=autosar.blocks.InternalTriggerBlock.findInternalTriggerBlocks(modelName);
                if~isempty(intTrigBlocks)
                    DAStudio.error('autosarstandard:code:InternalTriggerBlockInModelRef',...
                    getfullname(intTrigBlocks{1}));
                end


                autosar.mm.util.validateModel(modelName,'init');
            end

            if(Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName))
                interface=RTW.getClassInterfaceSpecification(modelName);
                interface.setClassName(modelName);
            end
        end

        function before_tlc(modelName,~,~,buildOpts,~,~)







            if autosar.build.BuildHooksImpl.isStandaloneBuild(modelName)&&~buildOpts.codeWasUpToDate
                bdir=RTW.getBuildDir(modelName);
                autosar.mm.mm2rte.RTEGenerator.createRTEFilesFolder(bdir.BuildDirectory);
            end
            coder.internal.xrel.AUTOSAR.AutosarExternalCodeImportHook.preTlcHook(modelName);
        end


        function after_tlc(modelName,~,~,buildOpts,~,buildInfo)











            autosar.mm.mm2rte.RTEGenerator.addStaticRTEHeaderFilesToBuildInfo(buildInfo);

            bdir=RTW.getBuildDir(modelName);

            if autosar.build.BuildHooksImpl.isStandaloneBuild(modelName)
                if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                    codeInfoFile=fullfile(bdir.BuildDirectory,'codeInfo.mat');
                    codeInfo=load('-mat',codeInfoFile);



                    useExecutor=slfeature('UseExecutorInAdaptiveAutosarMain')&&...
                    strcmp(get_param(modelName,'AdaptiveAutosarXCPSlaveTransportLayer'),'None');
                    if~useExecutor
                        staticHeaderPath=fullfile(autosarroot,'adaptive_deployment','include');
                        staticHeaderFiles={'MainUtils.hpp'};
                    else
                        staticHeaderPath=fullfile(matlabroot,'toolbox','coder','simulinkcoder','src','executor');
                        staticHeaderFiles={'PosixExecutor.hpp','WorkerPool.hpp','Timer.hpp'};


                        for i=1:length(staticHeaderFiles)
                            copyfile(fullfile(staticHeaderPath,staticHeaderFiles{i}),bdir.BuildDirectory,'f');
                        end




                        staticHeaderFiles={'PosixExecutor.hpp'};
                    end

                    buildInfo.addIncludePaths(staticHeaderPath);
                    buildInfo.addIncludePaths(fullfile(bdir.BuildDirectory,'stub','aragen'));
                    for fIdx=1:length(staticHeaderFiles)
                        buildInfo.addIncludeFiles(staticHeaderFiles{fIdx},staticHeaderPath);
                    end

                    xcpSupport=get_param(modelName,'AdaptiveAutosarXCPSlaveTransportLayer');
                    schemaVer=get_param(modelName,'AutosarSchemaVersion');
                    if strcmp(xcpSupport,'None')

                        if slfeature('UseExecutorInAdaptiveAutosarMain')
                            mainWriterObj=autosar.internal.adaptive.main.ExecutorMainWriter.create(codeInfo.codeInfo,schemaVer,bdir.BuildDirectory);
                        else
                            mainWriterObj=autosar.internal.adaptive.main.WriterBase.create(codeInfo.codeInfo,schemaVer,bdir.BuildDirectory);
                        end

                        mainWriterObj.generate();
                    else

                        xcpParams.AdaptiveAutosarXCPSlaveTransportLayer=xcpSupport;
                        xcpParams.AdaptiveAutosarXCPSlavePort=get_param(modelName,'AdaptiveAutosarXCPSlavePort');
                        xcpParams.AdaptiveAutosarXCPSlaveVerbosity=get_param(modelName,'AdaptiveAutosarXCPSlaveVerbosity');



                        mainWriterObj=autosar.internal.adaptive.main.WriterBase.create(codeInfo.codeInfo,schemaVer,bdir.BuildDirectory,[],xcpParams);
                        mainWriterObj.generate();



                        buildInfo.addDefines('-DXCP_SUPPORT_ADAPTIVE_AUTOSAR');



                        if strcmp(get_param(modelName,'AdaptiveAutosarUseCustomXCPSlave'),'off')
                            autosar.internal.adaptive.main.addXCPFilesToBuildInfo(buildInfo,xcpSupport);
                        end
                    end

                    [isAdaptiveToolchain,adapCmakeBuildVariant]=...
                    coder.internal.getAdaptiveCMakeBuildVariant(modelName);
                    if strcmp(adapCmakeBuildVariant,'STANDALONE_EXECUTABLE')||...
                        ~isAdaptiveToolchain
                        buildInfo.addSourceFiles(fullfile(bdir.BuildDirectory,'main.cpp'));
                    end

                    reportInfo=rtw.report.ReportInfo.instance(modelName);

                    for file=staticHeaderFiles
                        [p,f,e]=fileparts(fullfile(staticHeaderPath,file));
                        reportInfo.addFileInfo([f,e],'Other','header',p);
                    end
                end

                lIsXRel=coder.internal.xrel.AUTOSAR.AutosarExternalCodeImportHook.isAutosarCodeImport(modelName);
                if lIsXRel
                    coder.internal.xrel.AUTOSAR.AutosarExternalCodeImportHook.postTlcHook(modelName,buildInfo);
                else

                    autosarModelBuilder=autosar.build.BuildHooksImpl.buildM3IModel(modelName);
                end

                app2ImpMapIsUpToDate=true;
                codeInfoFile=fullfile(bdir.BuildDirectory,'codeInfo.mat');



                [typeReplaceMap,~,mode2ImpMap]=autosar.api.Utils.app2ImpMap(modelName);
                for modeGrpNames=mode2ImpMap.keys
                    replaceStr=mode2ImpMap(modeGrpNames{1});
                    findStr=modeGrpNames{1};
                    if~strcmp(findStr,replaceStr)
                        typeReplaceMap(findStr)=replaceStr;
                    end
                end



                if buildOpts.codeWasUpToDate
                    typeReplaceMapInCodeInfo=load('-mat',codeInfoFile,'typeReplaceMap');
                    app2ImpMapIsUpToDate=isequal(typeReplaceMapInCodeInfo.typeReplaceMap,typeReplaceMap);
                end

                if~buildOpts.codeWasUpToDate||~app2ImpMapIsUpToDate
                    if~lIsXRel
                        bdir=RTW.getBuildDir(modelName);
                        if contains(pwd,bdir.RelativeBuildDir)
                            lModelReferenceTargetType='NONE';
                        else
                            assert(contains(pwd,bdir.ModelRefRelativeBuildDir),...
                            'Must be in model reference build folder')
                            lModelReferenceTargetType='RTW';
                        end

                        [appTypeNamesUsedByModel,modeGroupNamesUsedByModel]=...
                        autosarModelBuilder.getAppTypeNamesUsedByModel();
                        autosar.code.CodeReplacementHelper.doTypeReplacement(modelName,...
                        appTypeNamesUsedByModel,...
                        modeGroupNamesUsedByModel,...
                        buildInfo.Settings.LocalAnchorDir,...
                        lModelReferenceTargetType);
                    end



                    save(codeInfoFile,'typeReplaceMap','-append');

                    if(Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName))
                        autosar.build.BuildHooksImpl.generateARAFiles(modelName,buildInfo);
                    else


                        codeDescriptor=coder.internal.getCodeDescriptorInternal(pwd,modelName,247362);
                        codeInfo=codeDescriptor.getComponentInterface();
                        expInports=codeDescriptor.getExpInports();
                        clear('codeDescriptor');
                        modelHeaderFile=[codeInfo.HeaderFile,'.h'];
                        autosar.build.BuildHooksImpl.generateRTEFiles(modelName,modelHeaderFile,buildInfo,codeInfo.Inports,expInports);
                    end
                end
            else


                assert(contains(pwd,bdir.ModelRefRelativeBuildDir),...
                'Must be in model reference build folder')
                autosar.code.CodeReplacementHelper.doTypeReplacement(modelName,{},{},...
                buildInfo.Settings.LocalAnchorDir,'RTW');



                reportInfo=rtw.report.ReportInfo.instance(modelName);
                autosar.mm.mm2rte.RTEGenerator.addStaticRTEHeaderFilesToReport(reportInfo);
            end
        end

        function before_make(modelName,~,~,hookBuildOpts,~,buildInfo)





            crlHelper=autosar.build.CRLHostLibraryHelper(modelName,buildInfo);
            crlHelper.handleRoutinesLibsInBuild();

            if autosar.build.BuildHooksImpl.isStandaloneBuild(modelName)&&...
                autosar.build.BuildHooksImpl.shouldGenerateXMLFiles(modelName)


                autosar.build.BuildHooksImpl.cleanUnusedTypesInM3IModel(modelName);


                msg=DAStudio.message('RTW:makertw:generatingXMLFiles',modelName);
                disp(msg);
                autosar.build.BuildHooksImpl.generateXMLFiles(modelName,buildInfo);
            end


            [~,lModelReferenceTargetType]=...
            findBuildArg(buildInfo,'MODELREF_TARGET_TYPE');
            isRefModel=strcmp(lModelReferenceTargetType,'RTW');

            if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)


                if autosar.build.BuildHooksImpl.isStandaloneBuild(modelName)
                    autosar.internal.adaptive.main.addToolchainOptionsToBuildinfo(...
                    modelName,buildInfo);
                elseif~isempty(hookBuildOpts.AutosarTopComponent)&&isRefModel

                    autosar.internal.adaptive.main.addToolchainOptionsToBuildinfo(...
                    modelName,buildInfo,hookBuildOpts.AutosarTopCodegenFolder);
                end
            else


                if~isempty(hookBuildOpts.AutosarTopComponent)&&isRefModel


                    autosar.mm.mm2rte.RTEGenerator.addGeneratedRTEIncludePathToSubModels...
                    (buildInfo,hookBuildOpts.AutosarTopCodegenFolder,...
                    hookBuildOpts.AutosarTopComponent);
                end
            end
        end

        function after_make(varargin)


        end

        function exit(modelName,~,~,~,~,~)


            if strcmp(get_param(modelName,'GenCodeOnly'),'off')
                msgID='RTW:makertw:exitRTWBuild';
            else
                msgID='RTW:makertw:exitRTWGenCodeOnly';
            end
            msg=DAStudio.message(msgID,modelName);
            disp(msg);
        end

    end

    methods(Static,Access=private)
        function isStandaloneBuild=isStandaloneBuild(modelName)
            mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
            isStandaloneBuild=strcmp(mdlRefTargetType,'NONE');
        end

        function autosarModelBuilder=buildM3IModel(modelName)


            codeDescriptor=coder.internal.getCodeDescriptorInternal(pwd,modelName,247362);
            expInports=codeDescriptor.getExpInports();


            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            messageReporter=autosar.mm.util.MessageReporter();
            msgStream.setReporter(messageReporter);
            msgStream.activate();
            msgStream.clear();

            autosarModelBuilder=autosar.mm.sl2mm.ModelBuilder(codeDescriptor,modelName,...
            expInports);
            autosarModelBuilder.build();
        end

        function cleanUnusedTypesInM3IModel(modelName)



            [isLinkedToInterfaceDict,dictFileName]=...
            autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(modelName);%#ok<ASGLU>
            if isLinkedToInterfaceDict


            else

                if~autosarcore.ModelUtils.isUsingSharedAutosarDictionary(modelName)
                    autosar.mm.sl2mm.M3IGarbageCollector.removeUnreferencedDataTypes(modelName);
                end
            end
        end

        function generateRTEFiles(modelName,modelHeaderFileName,buildInfo,inports,expInports)

            assert(autosar.build.BuildHooksImpl.isStandaloneBuild(modelName),...
            'RTE files should not be generated for Model reference code interface!');

            if(Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName))

                return
            end


            bdir=RTW.getBuildDir(modelName);
            rteDir=autosar.mm.mm2rte.RTEGenerator.getRTEFilesFolder(bdir.BuildDirectory);
            schemaVer=get_param(modelName,'AutosarSchemaVersion');
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
            modelMapping=autosar.api.Utils.modelMapping(modelName);
            errorStatusPortTable=autosar.mm.mm2rte.ErrorStatusPortTable.fromDataInterfaceArray(inports,expInports);
            signalInvalidationPortTable=autosar.mm.mm2rte.SignalInvalidationPortTable.fromModelMapping(modelMapping);

            rteGen=autosar.mm.mm2rte.RTEGenerator(m3iModel,m3iComp,schemaVer,...
            rteDir,modelHeaderFileName,maxShortNameLength,...
            errorStatusPortTable,signalInvalidationPortTable);
            reportInfo=rtw.report.ReportInfo.instance(modelName);
            rteGen.createRTEFiles(buildInfo,reportInfo);
        end

        function generateARAFiles(modelName,buildInfo)
            assert(autosar.build.BuildHooksImpl.isStandaloneBuild(modelName),...
            'ARA files should not be generated for Model reference code interface!');
            assert(Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName),'this function should be only called for autosar adaptive models.')

            bdir=RTW.getBuildDir(modelName);
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            araFilesLocation=autosar.mm.mm2ara.ARAGenerator.getARAFilesFolder(bdir.BuildDirectory);
            obj=autosar.mm.mm2ara.ARAGenerator(m3iModel,araFilesLocation,modelName);
            reportInfo=rtw.report.ReportInfo.instance(modelName);
            obj.createARAFiles(buildInfo,reportInfo);
        end

        function generateXMLFiles(modelName,buildInfo)




            arProps=autosar.api.getAUTOSARProperties(modelName);
            if~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)&&...
                strcmp(arProps.get('XmlOptions','XmlOptionsSource'),'Inherit')&&...
                strcmp(get_param(bdroot,'IsComponentBuildFromComposition'),'off')
                MSLDiagnostic('autosarstandard:exporter:CannotInheritXmlOptionsFromArchModel',modelName).reportAsWarning;
            end


            autosar.mm.arxml.Exporter.exportModel(modelName,'BuildInfo',buildInfo);


            arxmlFiles=autosar.api.internal.getExportedArxmlFileNames(modelName,...
            'IncludeStubFiles',false);


            fileNames=cell(1,length(arxmlFiles));
            filePaths=cell(1,length(arxmlFiles));
            for fIdx=1:length(arxmlFiles)
                arxmlFile=arxmlFiles{fIdx};
                [p,n,e]=fileparts(arxmlFile);
                fileNames{fIdx}=[n,e];
                filePaths{fIdx}=p;
            end
            buildInfo.addNonBuildFiles(fileNames,filePaths,'ARXML');


            if autosar.utils.Debug.validateXMLFiles()
                autosar.build.BuildHooksImpl.validateXMLFiles(arxmlFiles);
            end


            autosar.build.BuildHooksImpl.addXMLFilesToReport(modelName,arxmlFiles);
        end

        function validateXMLFiles(arxmlFiles)

            if isempty(arxmlFiles)
                return;
            end

            for ii=1:length(arxmlFiles)
                autosar.mm.arxml.Importer.validateFile(arxmlFiles{ii});
            end

        end

        function addXMLFilesToReport(modelName,arxmlFiles)

            if isempty(arxmlFiles)
                return;
            end

            try


                try
                    reportInfo=rtw.report.ReportInfo.instance(modelName);
                catch
                    reportInfo=[];
                end
                if isa(reportInfo,'rtw.report.ReportInfo')
                    reportInfo.removeTaggedFiles('arxml');
                    for ii=1:length(arxmlFiles)
                        arxmlFile=arxmlFiles{ii};
                        [filePath,fName,fExt]=fileparts(arxmlFile);
                        fileName=[fName,fExt];
                        reportInfo.addFileInfo(fileName,'interface','other',...
                        filePath,'arxml');
                    end
                end
            catch exceptionObj

                rethrow(exceptionObj);
            end
        end

        function shouldGenerateXML=shouldGenerateXMLFiles(modelName)

            isXRel=@()coder.internal.xrel.AUTOSAR.AutosarExternalCodeImportHook.isAutosarCodeImport(modelName);

            isATS=@()coder.connectivity.XILSubsystemUtils.isTopLevelBuildForATS(modelName);
            shouldGenerateXML=~(isXRel()||isATS());
        end
    end
end



