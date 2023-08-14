function checkPreconditions(obj)




    i_checkSimulation(obj.sourceModelName,obj.targetVersion)
    i_checkMDX(obj.sourceModelName,obj.targetVersion)
    i_checkIfHarness(obj.sourceModelName,obj.targetVersion)
    i_checkSubsystemReference(obj.sourceModelName,obj.targetVersion)
    i_checkInterfaceDict(obj.sourceModelName,obj.targetVersion);
    i_checkAUTOSAR(obj.sourceModelName,obj.targetVersion);
    i_checkArchitectureModel(obj.sourceModelName,obj.targetVersion)
    i_checkConfigSets(obj.sourceModelName,obj.targetVersion)
    i_checkHarnesses(obj.sourceModelName,obj.targetVersion);
    i_checkProtectedLibrary(obj.sourceModelName,obj.targetVersion);
    i_checkExportingInstanceParametersToMDL(obj)
end

function i_checkConfigSets(modelName,~)

    sets=getConfigSets(modelName);
    for i=1:length(sets)
        CSorCSR=getConfigSet(modelName,sets{i});
        if isa(CSorCSR,'Simulink.ConfigSetRef')
            try
                real_cs=CSorCSR.getRefConfigSet;
                if(isempty(real_cs))
                    DAStudio.error('Simulink:ExportPrevious:BadConfigSetRef');
                end
            catch E



                if strcmp(E.identifier,'Simulink:ConfigSet:ConfigSetRef_SourceNameNotInBaseWorkspace')
                    continue;
                else
                    rethrow(E);
                end
            end
        end
    end
end

function i_checkHarnesses(modelName,targetVersion)

    harnessList=Simulink.harness.find(modelName);
    numHarnesses=numel(harnessList);
    if numHarnesses>0
        if targetVersion.isR2014bOrEarlier


            id='Simulink:Harness:ExportToVersionDiscardsHarnessInfo';
            Simulink.output.highPriorityWarning(...
            MException(id,'%s',DAStudio.message(id)));
        elseif strcmp(targetVersion.format,'mdl')


            id='Simulink:Harness:ExportToMDLDiscardsHarnessInfo';
            Simulink.output.highPriorityWarning(...
            MException(id,'%s',DAStudio.message(id)));
        end
    end
end

function i_checkAUTOSAR(modelName,targetVersion)

    if Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture')&&...
        targetVersion<=saveas_version('R2019a')
        DAStudio.error('Simulink:ExportPrevious:AUTOSARArchModelsNotSupportedForExport');
    end




    if targetVersion<=saveas_version('R2021a')&&exist('autosarcore.ModelUtils','class')
        [isSharedDict,dictFiles]=autosarcore.ModelUtils.isUsingSharedAutosarDictionary(modelName);
        if isSharedDict
            assert(numel(dictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
            [~,f,e]=fileparts(dictFiles{1});
            dictFile=[f,e];
            msg=message('autosarstandard:dictionary:LinkedModelNotSupportedForExportToPrevious',modelName,dictFile);
            MSLException([],msg).throw();
        end
    end
end

function i_checkMDX(modelName,targetVersion)


    if configset.internal.util.isParamValueEqual(modelName,'SystemTargetFile','mdx.tlc')&&...
        targetVersion<=saveas_version('R2019b')
        DAStudio.error('Simulink:Engine:MDXNotSupportExportToPrevious');
    end
end

function i_checkIfHarness(modelName,~)


    if strcmp(get_param(modelName,'IsHarness'),'on')
        ownerBDName=get_param(modelName,'OwnerBDName');
        if~Simulink.harness.internal.isSavedIndependently(ownerBDName)
            DAStudio.error('Simulink:Harness:ExportToVersionNotSupportedForHarnessModel');
        end
    end

    hinfo=Simulink.harness.find(modelName,'OpenOnly','on');
    if~isempty(hinfo)
        DAStudio.error('Simulink:Harness:ExportToVersionNotSupportedActiveHarness',hinfo.name);
    end
end

function i_checkSubsystemReference(modelName,targetVersion)
    if bdIsSubsystem(modelName)
        if(targetVersion<=saveas_version('R2019a'))
            DAStudio.error('Simulink:Engine:ExportSubsystemUnsupportedRelease');
        end
    end
end


function i_checkArchitectureModel(modelName,targetVersion)
    if Simulink.internal.isArchitectureModel(modelName,'SoftwareArchitecture')&&...
        targetVersion<=saveas_version('R2020b')
        DAStudio.error('Simulink:ExportPrevious:SoftwareArchModelsNotSupportedForExport');
    end

    if Simulink.internal.isArchitectureModel(modelName)


        if~isempty(Simulink.harness.find(modelName))&&...
            targetVersion<=saveas_version('R2021a')
            DAStudio.error('SystemArchitecture:Architecture:ArchitectureExportWithHarnessToPre21b');
        end

        zcModel=get_param(modelName,'SystemComposerModel');
        zcModel.getImpl.verifyCanExportToPrevious(targetVersion.release)
    end
end

function i_checkInterfaceDict(modelName,targetVersion)



    if targetVersion<=saveas_version('R2022a')


        origWarn=warning('off','SLDD:sldd:DictionaryNotFound');
        restoreOrigWarn=onCleanup(@()warning(origWarn));
        interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
        if~isempty(interfaceDicts)
            msg=message('interface_dictionary:workflows:ModelWithInterfaceDictCannotExportToPrev');
            MSLException([],msg).throw();
        end
    end
end

function i_checkSimulation(modelName,~)
    if get_param(modelName,'SimulationStatus')~="stopped"
        error(message('Simulink:Commands:SaveAsDuringSimulation'));
    end
end

function i_checkProtectedLibrary(modelName,~)
    if get_param(modelName,'BlockDiagramType')=="library"
        f=get_param(modelName,'FileName');
        [~,~,ext]=slfileparts(f);
        if ext==".slxp"
            error(message('Simulink:Libraries:CannotSaveProtectedLibrary',modelName));
        end
    end
end





function i_checkExportingInstanceParametersToMDL(obj)
    if~obj.isSLX&&isR2021aOrEarlier(obj.targetVersion)&&~isR2018aOrEarlier(obj.targetVersion)
        modelBlocks=Simulink.findBlocksOfType(obj.sourceModelName,'ModelReference');

        for blockIndex=1:numel(modelBlocks)
            modelBlock=modelBlocks(blockIndex);

            instParams=get_param(modelBlock,'InstanceParameters');

            for paramIndex=1:numel(instParams)
                if instParams(paramIndex).Argument
                    DAStudio.error(...
                    'Simulink:modelReference:InstParam_RepromotedArgsCannotBeExportedAsMDL',...
                    obj.sourceModelFile,getfullname(modelBlock));
                end
            end
        end
    end
end


