function coderDictionaryXFinal(obj)







    newRules={};

    wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
    warning('off','RTW:configSet:migratedToCoderDictionary');
    wCleanup=onCleanup(@()warning(wState));

    if isR2022aOrEarlier(obj.ver)
        newRules{end+1}='<Simulink.FunctionDeployment:remove>';
        newRules{end+1}='<Simulink.DataReferenceClass<ServicePort:remove>>';
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<isFunctionPlatform:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<SignalDataTransfers:remove>>';
        end
    end

    if isR2021bOrEarlier(obj.ver)
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<DeploymentType:remove>>';
        end
    end

    if isR2020aOrEarlier(obj.ver)

        [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(obj.modelName);
        if~isempty(mapping)...
            &&any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
            for i=1:length(mapping.Inports)
                ports=get_param(mapping.Inports(i).Block,'PortHandles');
                port=ports.Outport;
                mapping.migrateInportMappingToEmbeddedSignalObject(port);
            end
        end


        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)


            mapping.unmapInports();
            mapping.unmapOutports();


            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<Inports:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<Outports:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<Parameters:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<ModelScopedParameters:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<Signals:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<States:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<DataStores:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<SynthesizedLocalDataStores:remove>>';
        end


        mapping=Simulink.CodeMapping.get(obj.modelName,'SimulinkCoderCTarget');
        if~isempty(mapping)


            mapping.unmap();


            newRules{end+1}='<Object<ClassName|"Simulink.CoderDictionary.ModelMappingSLC">:remove>';
        end






        coder.internal.CoderDataStaticAPI.replaceCDictRefWithCopy(obj.modelName);

    end

    if isR2019aOrEarlier(obj.ver)
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)
            newRules{end+1}='<Simulink.DataReferenceClass<Identifier:remove>>';
            newRules{end+1}='<Array<Type|"Simulink.CoderDictionary.StateMapping"><Object<StateIdentifier:rename Identifier>>>';
            newRules{end+1}='<Object<ClassName|"Simulink.CoderDictionary.StateMapping"><StateIdentifier:rename Identifier>>';
        end
    end

    if isR2018bOrEarlier(obj.ver)
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)

            for outMap=mapping.OutputFunctionMappings
                partitionName=outMap.PartitionName;
                if~isempty(partitionName)
                    newRules{end+1}=['<Simulink.CoderDictionary.PeriodicFunctionMapping<PartitionName|"',partitionName,'">:remove>'];%#ok<AGROW>
                end
            end
            for updMap=mapping.UpdateFunctionMappings
                partitionName=updMap.PartitionName;
                if~isempty(partitionName)
                    newRules{end+1}=['<Simulink.CoderDictionary.PeriodicFunctionMapping<PartitionName|"',partitionName,'">:remove>'];%#ok<AGROW>
                end
            end


            newRules{end+1}='<Array<Type|"Simulink.CoderDictionary.PeriodicFunctionMapping"><Object<PartitionName:remove>>>';
            newRules{end+1}='<Array<Type|"Simulink.CoderDictionary.PeriodicFunctionMapping"><Object<Id:remove>>>';
            newRules{end+1}='<Object<ClassName|"Simulink.CoderDictionary.PeriodicFunctionMapping"><PartitionName:remove>>';
            newRules{end+1}='<Object<ClassName|"Simulink.CoderDictionary.PeriodicFunctionMapping"><Id:remove>>';
        end
    end

    if isR2018aOrEarlier(obj.ver)
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)


            mapping.unmapFcnCalls();


            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<InitTermFunctions<InternalDataMemorySection:remove>>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<ExecutionFunctions<InternalDataMemorySection:remove>>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<SharedUtilityFunctions<InternalDataMemorySection:remove>>>';


            newRules{end+1}='<WILDCARD<FunctionReference:remove>>';


            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<ResetFunctions:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<AperiodicFunctionMappings:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<AsynchronousFunctionMappings:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<SubsystemFunctions:remove>>';
            newRules{end+1}='<Simulink.CoderDictionary.ModelMapping<FcnCallInports:remove>>';
        end
    end

    if isR2017bOrEarlier(obj.ver)
        mapping=Simulink.CodeMapping.get(obj.modelName,'CoderDictionary');
        if~isempty(mapping)

            newRules{end+1}='<ModelMappings<DefaultsMapping:remove>>';







            newRules{end+1}='<ModelMappings<Inports:remove>>';
            newRules{end+1}='<ModelMappings<Outports:remove>>';


            newRules{end+1}='<ModelMappings<FcnCallInports:remove>>';
            newRules{end+1}='<ModelMappings<OneShotFunctionMappings:remove>>';
            newRules{end+1}='<ModelMappings<OutputFunctionMappings:remove>>';
            newRules{end+1}='<ModelMappings<UpdateFunctionMappings:remove>>';
            newRules{end+1}='<ModelMappings<ResetFunctions:remove>>';
            newRules{end+1}='<ModelMappings<AperiodicFunctionMappings:remove>>';
            newRules{end+1}='<ModelMappings<AsynchronousFunctionMappings:remove>>';
        end
    end

    if isR2017bOrEarlier(obj.ver)&&...
        ~obj.targetVersion.isMDL&&...
        locIsSLXFile(obj.origModelName)&&...
        ~strcmp(get_param(obj.modelName,'BlockDiagramType'),'library')

        origMdlH=get_param(obj.origModelName,'Handle');
        cs=getActiveConfigSet(origMdlH);

        if isa(cs,'Simulink.ConfigSet')


            pkg=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(origMdlH);
            mapping=Simulink.CodeMapping.getCurrentMapping(obj.modelName);

            if~isempty(mapping)&&isa(mapping,'Simulink.CoderDictionary.ModelMapping')
                if~isempty(pkg)

                    set_param(obj.modelName,'MemSecPackage',pkg{1})


                    set_param(obj.modelName,'MemSecFuncInitTerm',locGetMemorySectionClass(origMdlH,'InitTermFunctions'))
                    set_param(obj.modelName,'MemSecFuncExecute',locGetMemorySectionClass(origMdlH,'ExecutionFunctions'))
                    set_param(obj.modelName,'MemSecFuncSharedUtil',locGetMemorySectionClass(origMdlH,'SharedUtilityFunctions'))


                    set_param(obj.modelName,'MemSecDataConstants',locGetMemorySectionClass(origMdlH,'Constants'))
                    set_param(obj.modelName,'MemSecDataIO',locGetMemorySectionClass(origMdlH,'Inports'))
                    set_param(obj.modelName,'MemSecDataInternal',locGetMemorySectionClass(origMdlH,'InternalData'))
                    set_param(obj.modelName,'MemSecDataParameters',locGetMemorySectionClass(origMdlH,'SharedParameters'))
                end


                set_param(obj.modelName,'CustomSymbolStrUtil',locGetSharedUtilityNamingRule(origMdlH))
            end
        end
    end

    obj.appendRules(newRules);

end

function out=locIsSLXFile(modelName)

    modelFile=get_param(modelName,'FileName');
    [~,~,fExt]=slfileparts(modelFile);
    out=strcmp(fExt,'.slx');

end

function className=locGetMemorySectionClass(mdlH,modelElementType)
    mapping=Simulink.CodeMapping.get(mdlH,'CoderDictionary');

    className='Default';
    if~isempty(mapping.DefaultsMapping.(modelElementType))
        uuidEntry='';



        referenceClassType='StorageClass';
        if(isequal(modelElementType,'InitTermFunctions')||...
            isequal(modelElementType,'ExecutionFunctions')||...
            isequal(modelElementType,'SharedUtilityFunctions'))
            referenceClassType='FunctionClass';
        end
        if~isempty(mapping.DefaultsMapping.(modelElementType).(referenceClassType))
            uuidEntry=mapping.DefaultsMapping.(modelElementType).(referenceClassType).UUID;
        elseif~isempty(mapping.DefaultsMapping.(modelElementType).MemorySection)
            uuidEntry=mapping.DefaultsMapping.(modelElementType).MemorySection.UUID;
        end
        if~isempty(uuidEntry)
            nameEntry=mapping.DefaultsMapping.getMemorySectionNameFromUuid(uuidEntry);
            [~,tmpClassName]=coder.internal.CoderDataStaticAPI.getLegacyMemorySectionInfo(mdlH,nameEntry);
            if~isempty(tmpClassName)


                className=tmpClassName;
            end
        end
    end
end

function namingRule=locGetSharedUtilityNamingRule(mdlH)
    namingRule='$N$C';

    mapping=Simulink.CodeMapping.get(mdlH,'CoderDictionary');

    if~isempty(mapping.DefaultsMapping.SharedUtilityFunctions)
        uuidEntry='';
        if~isempty(mapping.DefaultsMapping.SharedUtilityFunctions.FunctionClass)
            uuidEntry=mapping.DefaultsMapping.SharedUtilityFunctions.FunctionClass.UUID;
        end

        if~isempty(uuidEntry)
            fcName=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateNameFromUuid(...
            mdlH,uuidEntry,'SharedUtility');

            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            dd=hlp.openDD(mdlH);
            fcEntry=hlp.findEntry(dd,'FunctionClass',fcName);

            namingRule=hlp.getProp(fcEntry,'FunctionName');
        end
    end

end


