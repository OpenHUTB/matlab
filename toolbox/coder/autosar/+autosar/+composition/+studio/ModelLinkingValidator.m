classdef ModelLinkingValidator








    properties(Access=private)
        RefModelName;
        RefModelFileName;
        IsUIMode;
        IsAdaptiveArch;
        CompositionHdl;
        CompBlkHdl;
        LinkingFixer;
    end

    methods(Access=public)
        function obj=ModelLinkingValidator(compBlkHdl,...
            compositionHdl,refModelFileName,isUIMode,isAdaptiveArch)
            obj.CompBlkHdl=compBlkHdl;
            obj.CompositionHdl=compositionHdl;
            obj.RefModelFileName=refModelFileName;
            [~,refModelName,~]=fileparts(refModelFileName);
            obj.RefModelName=refModelName;
            obj.IsUIMode=isUIMode;
            obj.IsAdaptiveArch=isAdaptiveArch;
            obj.LinkingFixer=autosar.composition.studio.ModelLinkingFixer(...
            compBlkHdl,compositionHdl,refModelFileName,isUIMode,isAdaptiveArch);
        end



        function validateModelValidForLinking(this)



            this.validateFileFormat();

            this.validateUnmappableBusPorts();
        end


        function valMsgs=validateRequirements(obj)






            valMsgs=struct;

            if(slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
                autosar.composition.Utils.isCompositionBlock(obj.CompBlkHdl)






                valMsgs.failures.complianceFail='';
                valMsgs.failures.mappingFail='';
                valMsgs.failures.dictionaryMigrationCheckFail='';
                valMsgs.warnings.dummyWarn='';
                valMsgs.flags.IsLinkingAUTOSARModel=false;
                valMsgs.flags.HasLinkedArchitectureDictionary=false;
                return;
            end


            [valMsgs.failures.complianceFail,valMsgs.warnings.stfWarn]=obj.checkAUTOSARCompliance;
            valMsgs.failures.solverTypeFail=obj.checkSolverType;
            [valMsgs.failures.dictionaryMigrationCheckFail,...
            valMsgs.flags.IsLinkingAUTOSARModel,...
            valMsgs.flags.HasLinkedArchitectureDictionary,...
            valMsgs.flags.InterfaceDictionaryMigrator,...
            valMsgs.flags.ConflictsBehavior,...
            valMsgs.flags.Conflicts]=obj.checkForDictionaryConflicts;
            [valMsgs.failures.mappingFail,valMsgs.warnings.ioWarn]=obj.checkMapping;

            [valMsgs.warnings.InterfaceDictUnmappablePorts,...
            valMsgs.warnings.InterfaceDictUnconvertableSignalPorts]=obj.checkUnmappablePortsForInterfaceDictionary;

            if~obj.IsAdaptiveArch
                [valMsgs.failures.portsFail,valMsgs.warnings.bepWarn]=obj.checkBusPorts;
            else


                valMsgs.failures.portsFail='';
            end
            valMsgs.warnings.multiTaskWarn=obj.checkMultiTasking;
            if autosar.api.Utils.isMapped(obj.RefModelName)

                valMsgs.msgs.xmlOpts=obj.checkInheritXmlOptions;
            else
                valMsgs.msgs.xmlOpts='';
            end
        end

        function isAdaptiveArch=getArchType(obj)
            isAdaptiveArch=obj.IsAdaptiveArch;
        end
    end

    methods(Access=private)


        function validateFileFormat(obj)


            if(slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
                autosar.composition.Utils.isCompositionBlock(obj.CompBlkHdl)


                return;
            end


            if~autosar.composition.Utils.isComponentBlock(obj.CompBlkHdl)
                assert(false,'Can only link component blocks');
            end


            [filepath,refModelName,ext]=fileparts(obj.RefModelFileName);
            if(isempty(ext))
                ext='.slx';
            end


            if exist(obj.RefModelFileName,'file')==0

                if(isempty(filepath))
                    filepath=fullfile(pwd);
                end
            end


            if~isvarname(refModelName)
                msgId='autosarstandard:editor:InvalidModelName';
                DAStudio.error(msgId,refModelName);
            end

            if exist(obj.RefModelFileName,'file')==0&&...
                exist(fullfile(filepath,[refModelName,ext]),'file')==0

                msgId='Simulink:LoadSave:FileNotFound';
                DAStudio.error(msgId,fullfile(filepath,[refModelName,ext]));
            end


            if strcmpi(ext,'.slxp')
                msgId='autosarstandard:editor:CannotLinkToProtectedModelError';
                DAStudio.error(msgId,[refModelName,ext]);
            end



            fileFormat=Simulink.loadsave.identifyFileFormat(obj.RefModelFileName);
            if strcmpi(fileFormat,'mdl')
                msgId='autosarstandard:editor:CannotLinkToLegacyMdlExtension';
                DAStudio.error(msgId,[refModelName,ext]);
            end


            if~bdIsLoaded(refModelName)
                load_system(obj.RefModelFileName);
            end


            if strcmp(get_param(refModelName,'BlockDiagramType'),'library')
                msgId='autosarstandard:editor:CannotLinkToLibraryModel';
                DAStudio.error(msgId,refModelName);
            end


            if autosar.api.Utils.isMappedToComposition(refModelName)

                msgId='autosarstandard:editor:CompRefCannotReferenceComposition';
                DAStudio.error(msgId);
            end
        end

        function validateUnmappableBusPorts(obj)
            if autosar.composition.Utils.isCompositionBlock(obj.CompBlkHdl)

                return;
            end
            busElementPortsAtRoot=autosar.simulink.bep.Utils.findBusElementPortsAtRoot(obj.RefModelName);
            unmappableBEPs=busElementPortsAtRoot(...
            arrayfun(@(x)autosar.validation.CommonModelingStylesValidator.busElementIsInvalid(x),...
            busElementPortsAtRoot));
            if~isempty(unmappableBEPs)
                blockPaths=arrayfun(@(x)getfullname(x),unmappableBEPs,'UniformOutput',false);
                DAStudio.error('autosarstandard:editor:UnmappableBusPorts',...
                obj.RefModelName,autosar.api.Utils.cell2str(blockPaths));
            end
        end

        function[msg,stfWarn]=checkAUTOSARCompliance(obj)

            msg='';
            stfWarn='';
            targetLang=get_param(obj.RefModelName,'TargetLang');
            refModelHasAppropriateTargetLang=...
            (obj.IsAdaptiveArch&&strcmp(targetLang,'C++')||...
            (~obj.IsAdaptiveArch&&strcmp(targetLang,'C')));
            if~(strcmp(get_param(obj.RefModelName,'AutosarCompliant'),'on')&&...
                refModelHasAppropriateTargetLang)
                msgId='autosarstandard:editor:CompRefModelSTFMismatch';
                if obj.IsUIMode

                    msg=DAStudio.message(msgId,obj.RefModelName);
                    if obj.IsAdaptiveArch
                        stfWarn=DAStudio.message('autosarstandard:ui:uiNeedsAdaptiveTarget');
                    else
                        stfWarn=DAStudio.message('autosarstandard:ui:uiNeedsClassicTarget');
                    end
                else

                    DAStudio.error(msgId,obj.RefModelName);
                end
            end
        end

        function msg=checkSolverType(obj)
            msg='';
            activeConfigSet=autosar.utils.getActiveConfigSet(obj.RefModelName);
            if strcmp(get_param(activeConfigSet,'SolverType'),'Variable-step')

                msg=DAStudio.message('autosarstandard:ui:uiFixedStepRequirement');
            end
        end

        function[msg,ioWarn]=checkMapping(obj)

            msg='';
            ioWarn='';

            if~autosar.api.Utils.isMapped(obj.RefModelName)
                msgId='autosarstandard:editor:CompRefModelNotMapped';
                if obj.IsUIMode
                    msg=DAStudio.message(msgId,obj.RefModelName);
                else

                    DAStudio.error(msgId,obj.RefModelName);
                end
            elseif autosar.api.Utils.isMappedToAdaptiveApplication(obj.RefModelName)
                if~obj.IsAdaptiveArch||~slfeature('AdaptiveArchitectureModeling')

                    msgId='autosarstandard:editor:CompRefCannotReferenceAdaptiveInClassicArch';
                    DAStudio.error(msgId);
                end
            elseif autosar.api.Utils.isMappedToComponent(obj.RefModelName)
                [~,mapping]=autosar.api.Utils.isMappedToComponent(obj.RefModelName);
                if mapping.IsSubComponent

                    DAStudio.error('autosarstandard:editor:NoSubComponentMapping');
                end

                try
                    mapping.validateIO();
                catch ME
                    msg='';
                    for i=1:length(ME.cause)
                        if i==1
                            msg=ME.cause{i}.message;
                        else
                            msg=strcat(msg," ",ME.cause{i}.message);
                        end
                    end
                    ioWarn=msg;
                end
            end
        end

        function[fail,isLinkingAUTOSARModel,hasLinkedInterfaceDictionary,migrator,conflictsBehaviour,conflicts]=...
            checkForDictionaryConflicts(obj)
            fail='';
            migrator='';
            conflicts={};
            conflictsBehaviour='Error';

            archInterfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(get_param(obj.CompositionHdl,'handle'));
            compInterfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(get_param(obj.RefModelName,'handle'));
            canMigrateToArchInterfaceDict=numel(archInterfaceDicts)==1;
            canMigrateToCompInterfaceDict=numel(compInterfaceDicts)==1;

            isLinkingAUTOSARModel=autosar.api.Utils.isMappedToComponent(obj.RefModelName);

            hasLinkedInterfaceDictionary=canMigrateToArchInterfaceDict||canMigrateToCompInterfaceDict;






            if canMigrateToCompInterfaceDict&&~isLinkingAUTOSARModel
                interfaceDictionaryToMigrate=autosar.utils.File.dropPath(compInterfaceDicts{1});
            elseif canMigrateToArchInterfaceDict&&~isLinkingAUTOSARModel
                interfaceDictionaryToMigrate=autosar.utils.File.dropPath(archInterfaceDicts{1});
            else
                return;
            end

            migrator=Simulink.interface.dictionary.Migrator(...
            obj.RefModelName,...
            'InterfaceDictionaryName',interfaceDictionaryToMigrate,...
            'DeleteFromOriginalSource',true);




            migrator.analyze();

            dataTypesToMigrate=migrator.DataTypesToMigrate;
            interfacesToMigrate=migrator.InterfacesToMigrate;
            conflictObjects=migrator.ConflictObjects;

            if~(isempty(dataTypesToMigrate)&&isempty(interfacesToMigrate)&&isempty(conflictObjects))
                if~isempty(conflictObjects)
                    fail='FailWithConflicts';
                    for i=1:length(conflictObjects)


                        entry=conflictObjects{i};
                        for l=1:length(entry)
                            item=entry{l};
                            if~strcmp(item.Source,interfaceDictionaryToMigrate)
                                conflicts{end+1}={item.Name,item.Source};%#ok
                            end
                        end
                    end
                else
                    fail='Fail';
                end
            end
        end

        function[unmappablePortWarnings,unconvertablePortWarnings]=checkUnmappablePortsForInterfaceDictionary(obj)





            unmappablePortWarnings={};
            unconvertablePortWarnings={};

            refModelInterfaceDictPaths=SLDictAPI.getTransitiveInterfaceDictsForModel(get_param(obj.RefModelName,'handle'));
            if isempty(refModelInterfaceDictPaths)

                return
            end


            unmappablePortNames=autosar.validation.InterfaceDictionaryValidator.findRootLevelBEPsUsingNonInterfaceDictInterfaces(...
            obj.RefModelName,refModelInterfaceDictPaths,IncludeInlinedInterfaces=true);



            findSystemOpts={'SearchDepth',1,'IsComposite','off'};
            inportFindSystemOpts=[findSystemOpts,{'OutputFunctionCall','off'}];
            refModelInports=find_system(obj.RefModelName,inportFindSystemOpts{:},'BlockType','Inport');
            refModelOutports=find_system(obj.RefModelName,findSystemOpts{:},'BlockType','Outport');
            refModelSignalPorts=[refModelInports,refModelOutports];
            unconvertableSignalPortNames={};
            for i=1:length(refModelInterfaceDictPaths)
                refModelInterfaceDictPath=refModelInterfaceDictPaths{i};
                interfaceDictObj=Simulink.interface.dictionary.open(refModelInterfaceDictPath);
                for signalPortIdx=1:numel(refModelSignalPorts)
                    signalPortName=refModelSignalPorts{signalPortIdx};






                    unconvertableSignalPortNames{end+1}=signalPortName;%#ok<AGROW>
                    continue;
                end

                if autosar.api.Utils.isMapped(obj.RefModelName)&&~isempty(unmappablePortNames)


                    refModelMapping=autosar.api.Utils.modelMapping(obj.RefModelName);
                    refModelMappedSlPorts=[refModelMapping.Inports,refModelMapping.Outports];
                    for refModelMappedPortIdx=1:numel(refModelMappedSlPorts)
                        mappedSlPortBlk=refModelMappedSlPorts(refModelMappedPortIdx).Block;
                        mappedSlPortName=get_param(mappedSlPortBlk,'Name');
                        if any(contains(unmappablePortNames,mappedSlPortName))
                            unmappablePortNames(contains(unmappablePortNames,mappedSlPortName))=[];
                        end
                    end
                end

                if~isempty(unmappablePortNames)
                    unmappablePortWarnings{end+1}=DAStudio.message('autosarstandard:dictionary:InterfaceDictCannotAutoMapPorts',...
                    autosar.api.Utils.cell2str(unmappablePortNames),interfaceDictObj.DictionaryFileName);%#ok
                end

                if~isempty(unconvertableSignalPortNames)

                    unconvertablePortWarnings{end+1}=DAStudio.message('autosarstandard:dictionary:InterfaceDictCannotConvertSignalPorts',...
                    autosar.api.Utils.cell2str(unconvertableSignalPortNames));%#ok
                end
            end
        end

        function[msg,bepWarn]=checkBusPorts(obj)


            msg='';
            bepWarn='';
            findSystemOpts={'SearchDepth',1,'IsComposite','off'};
            inportFindSystemOpts=[findSystemOpts,{'OutputFunctionCall','off'}];

            refModelInports=find_system(obj.RefModelName,inportFindSystemOpts{:},'BlockType','Inport');
            refModelOutports=find_system(obj.RefModelName,findSystemOpts{:},'BlockType','Outport');


            if~isempty(refModelInports)||~isempty(refModelOutports)
                refModelhasRegularPorts=1;

                if autosar.api.Utils.isMappedToComponent(obj.RefModelName)
                    slMap=autosar.api.getSimulinkMapping(obj.RefModelName);


                    flaggedDataAccessModes={'ErrorStatus','IsUpdated'};
                    inportDataAccessModes=cell(1,length(refModelInports));
                    for i=1:length(refModelInports)
                        currentRefModelInport=get_param(refModelInports{i},'Name');
                        [~,~,inportDataAccessMode]=getInport(slMap,currentRefModelInport);
                        inportDataAccessModes{i}=inportDataAccessMode;
                    end

                    if any(ismember(inportDataAccessModes,flaggedDataAccessModes))

                        bepWarn=DAStudio.message('autosarstandard:ui:uiCannotConvertPorts');
                    end

                    if~isempty(inportDataAccessModes)&&all(ismember(inportDataAccessModes,flaggedDataAccessModes))

                        return;
                    end
                end
            else
                refModelhasRegularPorts=0;
            end

            if refModelhasRegularPorts

                bepWarn=obj.canConvertToBEPs;
                if obj.IsUIMode

                    msg=DAStudio.message('autosarstandard:editor:ConvertToBEPsWarning',obj.RefModelName);
                else


                    obj.LinkingFixer.fixBusPorts;
                end
            end
        end

        function msg=canConvertToBEPs(obj)



            msg='';
            if autosar.api.Utils.isMapped(obj.RefModelName)
                [canConvertToBEPs,msgID,bepMsg]=...
                autosar.simulink.bep.RefactorModelInterface.canRefactorModelInterfaceBeforeLinking(obj.RefModelName);

                if~canConvertToBEPs

                    if obj.IsUIMode
                        msg=bepMsg;
                    else
                        if slfeature('RootBEPVariantSupport')==0&&...
                            strcmp(msgID,'autosarstandard:editor:BepConversionVariant')...

                            mexcept=MException(msgID,bepMsg);
                            mexcept.throw();
                        else
                            bepMsg=message(msgID,obj.RefModelName);
                            obj.reportMessage(bepMsg,'warning');
                        end
                    end
                end
            end

            if~obj.IsUIMode

                obj.isDirty;
            end
        end

        function isDirty(obj)
            if strcmp(get_param(obj.RefModelName,'Dirty'),'on')
                msgID='autosarstandard:editor:BepConversionUnsavedChanges';
                DAStudio.error(msgID,obj.RefModelName);
            end
        end

        function msg=checkMultiTasking(obj)


            msg='';
            rootCompositionName=get_param(obj.CompositionHdl,'Name');
            multiTaskingEnabled=get_param(rootCompositionName,'EnableMultiTasking');
            if strcmp(multiTaskingEnabled,'off')
                msgId='autosarstandard:editor:ArchModelNoMultitasking';
                if obj.IsUIMode
                    msg=DAStudio.message('autosarstandard:ui:uiMultitaskWarning');
                else

                    DAStudio.error(msgId,rootCompositionName);
                end
            end
        end

        function reportMessage(obj,message,reportType)

            assert(ismember(reportType,{'info','warning'}),...
            'Errors should be thrown via DAStudio.error or exceptions directly');
            if obj.IsUIMode

                mException=MException(message.Identifier,'%s',message.getString());
                stageName=DAStudio.message('autosarstandard:editor:AutosarLinkingStage');
                autosar.utils.DiagnosticViewer.report(mException,reportType,...
                stageName,obj.RefModelName);
            else
                switch reportType
                case 'info'
                    Simulink.output.info(message.getString());
                case 'warning'
                    MSLDiagnostic(message.Identifier,message.Arguments{:}).reportAsWarning;
                otherwise
                    assert(false,'Cannot get here');
                end
            end
        end
    end

    methods(Access=public)
        function msg=checkInheritXmlOptions(obj)


            msg='';

            apiObj=autosar.api.getAUTOSARProperties(...
            obj.RefModelName);




            if~strcmp(apiObj.get('XmlOptions','XmlOptionsSource'),'Inherit')&&...
                ~autosar.api.Utils.isUsingSharedAutosarDictionary(obj.RefModelName)

                apiObj.set('XmlOptions','XmlOptionsSource','Inherit');

                if obj.IsUIMode
                    msg=DAStudio.message('autosarstandard:editor:NotificationXmlOptionsSource',...
                    obj.RefModelName);
                else

                    warnMsg=message('autosarstandard:editor:NotificationXmlOptionsSource',...
                    obj.RefModelName);
                    obj.reportMessage(warnMsg,'info');
                end
            end
        end
    end
end


