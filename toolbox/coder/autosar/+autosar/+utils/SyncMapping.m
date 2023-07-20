classdef SyncMapping










    properties(Constant,Access=private)
        SearchArgs=autosar.utils.SyncMapping.getSearchArgs();
    end

    methods(Static)
        function syncStatesSignalsAndDSMs(modelName)




            modelName=get_param(modelName,'Name');

            slMapping=autosar.api.getSimulinkMapping(modelName);
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iModel=m3iComp.rootModel;

            if~m3iComp.Behavior.isvalid()
                return;
            end

            changeLogger=autosar.updater.ChangeLogger;
            sysConstsValueMap=autosar.api.Utils.createSystemConstantMap(m3iModel,[],[]);
            pbVarCritValueMap=autosar.api.Utils.createPostBuildVariantCriterionMap(m3iModel,[],[]);

            slTypeBuilder=autosar.mm.mm2sl.TypeBuilder(m3iModel,false,'base',changeLogger,sysConstsValueMap,pbVarCritValueMap);
            slTypeBuilder.buildAllDataTypeMappings(m3iModel);


            arTypedPIMSeq=m3iComp.Behavior.ArTypedPIM;
            staticMemorySeq=m3iComp.Behavior.StaticMemory;


            unMappedArTypedPIM=autosar.utils.SyncMapping.mapStatesSignalsAndDSMs(arTypedPIMSeq,modelName,'ArTypedPerInstanceMemory',slMapping,slTypeBuilder);
            unMappedStaticMemory=autosar.utils.SyncMapping.mapStatesSignalsAndDSMs(staticMemorySeq,modelName,'StaticMemory',slMapping,slTypeBuilder);

            unMappedPims=[unMappedArTypedPIM,unMappedStaticMemory];

            searchArgs=autosar.utils.SyncMapping.SearchArgs;
            dsmPaths=find_system(modelName,searchArgs{:},'BlockType','DataStoreMemory');
            dswPaths=find_system(modelName,searchArgs{:},'BlockType','DataStoreWrite');
            dsrPaths=find_system(modelName,searchArgs{:},'BlockType','DataStoreRead');

            dataStorePaths=[dsmPaths;dswPaths;dsrPaths];
            dsmNames=get_param(dataStorePaths,'DataStoreName');
            dsmNames=unique(dsmNames);
            [exists,sigObj,inModelWS]=autosar.utils.Workspace.objectExistsInModelScope(modelName,dsmNames);
            validConversionSignal=cellfun(@(exists_,sigObj_,inModelWS_)exists_&&isa(sigObj_,'Simulink.Signal')&&inModelWS_,exists,sigObj,inModelWS);
            dsmsNeedinglegacySigObj=dsmNames(validConversionSignal);
            unMappedPims=unMappedPims(ismember(unMappedPims,dsmsNeedinglegacySigObj));

            if~isempty(unMappedPims)
                autosar.mm.mm2sl.SignalBuilder.buildLegacySignals(modelName,unMappedPims,slTypeBuilder);
            end
        end
    end

    methods(Static,Access=private)
        function args=getSearchArgs()

            args={'FollowLinks',1,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants};
        end

        function unMappedPims=mapStatesSignalsAndDSMs(m3iSeq,modelName,type,slMapping,slTypeBuilder)

            import autosar.utils.SyncMapping

            if~ischar(modelName)
                modelName=get_param(modelName,'Name');
            end

            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            modelMapping=autosar.api.Utils.modelMapping(modelName);

            unMappedPims={};
            for ii=1:m3iSeq.size()
                m3iData=m3iSeq.at(ii);
                name=m3iData.Name;

                [doesExist,sigObj,inModelWorkSpace]=autosar.utils.Workspace.objectExistsInModelScope(modelName,name);

                if doesExist


                    if isa(sigObj,'AUTOSAR.Signal')&&~inModelWorkSpace

                        continue;
                    elseif isa(sigObj,'Simulink.Signal')...
                        &&strcmp(sigObj.CoderInfo.StorageClass,'ExportedGlobal')...
                        &&strcmp(type,'StaticMemory')

                        continue;
                    end
                end


                signalMapping=SyncMapping.getMappingWithShortName(modelMapping.Signals,slMapping,name);
                stateMapping=SyncMapping.getMappingWithShortName(modelMapping.States,slMapping,name);
                dsmMapping=SyncMapping.getMappingWithShortName(modelMapping.DataStores,slMapping,name);
                synthDSMMapping=SyncMapping.getMappingWithShortName(modelMapping.SynthesizedDataStores,slMapping,name);

                existingMappings=[signalMapping,stateMapping,dsmMapping,synthDSMMapping];
                assert(sum(~isempty(existingMappings))<=1,'No more than one existing mapping should be present');

                pimMapping=existingMappings(~strcmp({existingMappings.mappingCategory},'None'));



                if isempty(pimMapping)


                    signalsMatchingName=SyncMapping.findSignalsWithName(modelName,name);
                    stateflowSignalsIdx=SyncMapping.isStateflowSignal(signalsMatchingName);
                    stateflowSignals=signalsMatchingName(stateflowSignalsIdx);


                    signalsMatchingName(stateflowSignalsIdx)=[];
                    signalsMatchingName(SyncMapping.isSignalUnconnected(signalsMatchingName))=[];

                    if~isempty(signalsMatchingName)
                        signalsMatchingName=SyncMapping.selectPreferredSignalToMap(signalsMatchingName);
                    end


                    statesMatchingName=SyncMapping.findStatesWithName(modelName,name);



                    ignoreStateBlkIdxs=cellfun(@(x)~isfield(get_param(x,'DialogParameters'),'StateName'),statesMatchingName);
                    statesMatchingName(ignoreStateBlkIdxs)=[];


                    dsmsMatchingName=SyncMapping.findDSMsWithName(modelName,name);


                    synthesizedDSMsMatchingName=[];
                    if slfeature('ArSynthesizedDS')>0
                        if doesExist&&isa(sigObj,'Simulink.Signal')&&inModelWorkSpace


                            synthesizedDSMsMatchingName=SyncMapping.findSynthesizedDSMsWithName(modelName,name);
                            if~isempty(synthesizedDSMsMatchingName)


                                synthesizedDSMsMatchingName=synthesizedDSMsMatchingName(1);
                            end
                        end
                    end







                    isStateflowDSM=false;
                    if~isempty(signalsMatchingName)

                        stateflowSignals=[];
                    else
                        dsmParents=get_param(dsmsMatchingName,'Parent');
                        isStateflowDSM=SyncMapping.isStateflowDataStoreSignal(modelName,name,dsmParents);
                    end


                    if(numel(signalsMatchingName)...
                        +numel(statesMatchingName)...
                        +numel(dsmsMatchingName)...
                        +numel(synthesizedDSMsMatchingName)...
                        +numel(stateflowSignals)...
                        +isStateflowDSM)>1

                        autosar.mm.util.MessageReporter.createWarning('autosarstandard:validation:cannotMapMultipleSignalOrState',name);
                        continue;
                    end

                    pimMapping=autosar.utils.SyncMapping.getPimMappingStruct();

                    if~isempty(signalsMatchingName)
                        if iscell(signalsMatchingName),signalsMatchingName=signalsMatchingName{1};end
                        pimMapping.mappingCategory='Signal';
                        pimMapping.mappedSLRef=get_param(signalsMatchingName,'SrcPortHandle');
                    end

                    if~isempty(statesMatchingName)
                        if iscell(statesMatchingName),statesMatchingName=statesMatchingName{1};end
                        pimMapping.mappingCategory='State';
                        pimMapping.mappedSLRef=getfullname(get_param(statesMatchingName,'Handle'));
                    end

                    if~isempty(dsmsMatchingName)
                        if iscell(dsmsMatchingName),dsmsMatchingName=dsmsMatchingName{1};end
                        pimMapping.mappingCategory='DSM';
                        pimMapping.mappedSLRef=getfullname(get_param(dsmsMatchingName,'Handle'));
                    end

                    if~isempty(synthesizedDSMsMatchingName)
                        if iscell(synthesizedDSMsMatchingName),synthesizedDSMsMatchingName=synthesizedDSMsMatchingName{1};end
                        pimMapping.mappingCategory='SynthesizedDSM';
                        pimMapping.mappedSLRef=get_param(synthesizedDSMsMatchingName,'DataStoreName');
                    end
                end

                if strcmp(pimMapping.mappingCategory,'None')
                    if doesExist





                        isStateflowDSM=SyncMapping.isStateflowDataStoreSignal(modelName,name);
                        if isStateflowDSM
                            autosar.mm.mm2sl.SignalBuilder.buildLegacySignals(modelName,name,slTypeBuilder);
                            continue;
                        end
                    end


                    exists=existsInGlobalScope(modelName,name);
                    if exists
                        sigObj=evalinGlobalScope(modelName,name);
                    end
                    if~(exists&&autosar.mm.mm2sl.SignalBuilder.isLegacyPIMSignalObject(sigObj))

                        unMappedPims=[unMappedPims,name];%#ok<AGROW>
                    end

                    continue;
                end

                mappingArgs=SyncMapping.getMappingArguments(m3iData,slTypeBuilder);

                switch pimMapping.mappingCategory
                case 'Signal'
                    try
                        addSignal(slMapping,pimMapping.mappedSLRef);
                        signalMapping=getSignal(slMapping,pimMapping.mappedSLRef);
                    catch ME
                        if strcmp(ME.identifier,'coderdictionary:api:invalidMappingAutosarSignalPort')

                            continue;
                        else
                            ME.rethrow();
                        end
                    end

                    if strcmp(signalMapping,'Auto')
                        slMapping.mapSignal(...
                        pimMapping.mappedSLRef,...
                        type,...
                        mappingArgs{:});
                    end
                case 'State'
                    if strcmp(slMapping.getState(pimMapping.mappedSLRef,name),'Auto')
                        slMapping.mapState(...
                        pimMapping.mappedSLRef,name,...
                        type,...
                        mappingArgs{:});
                    end
                case 'DSM'
                    if SyncMapping.needsNVRAMAccess(m3iComp,name)
                        mappingArgs=[mappingArgs,'NeedsNVRAMAccess','true'];%#ok<AGROW>
                    end
                    if strcmp(slMapping.getDataStore(pimMapping.mappedSLRef),'Auto')
                        slMapping.mapDataStore(...
                        pimMapping.mappedSLRef,...
                        type,...
                        mappingArgs{:});
                    end
                case 'SynthesizedDSM'
                    if SyncMapping.needsNVRAMAccess(m3iComp,name)
                        mappingArgs=[mappingArgs,'NeedsNVRAMAccess','true'];%#ok<AGROW>
                    end
                    if strcmp(slMapping.getSynthesizedDataStore(pimMapping.mappedSLRef),'Auto')
                        slMapping.mapSynthesizedDataStore(...
                        pimMapping.mappedSLRef,...
                        type,...
                        mappingArgs{:});
                    end
                otherwise
                    assert(false,'Expected a mapping category');
                end
            end
        end

        function m3iImpType=getM3IImpType(m3iVarData,slTypeBuilder)
            m3iType=m3iVarData.Type;
            if m3iType.IsApplication
                impQName=slTypeBuilder.getImplementationDataType(m3iType.qualifiedName);
                m3iSeq=autosar.mm.Model.findObjectByName(m3iType.rootModel,impQName);
                m3iImpType=m3iSeq.at(1);
            else
                m3iImpType=m3iType;
            end
        end

        function signalsMatchingName=findSignalsWithName(modelName,name)
            searchArgs=autosar.utils.SyncMapping.SearchArgs;
            signalsMatchingName=find_system(modelName,...
            'FindAll','on',...
            searchArgs{:},...
            'type','line',...
            'SegmentType','trunk',...
            'Name',name);
        end

        function statesMatchingName=findStatesWithName(modelName,name)
            searchArgs=autosar.utils.SyncMapping.SearchArgs;
            statesMatchingName=find_system(modelName,...
            searchArgs{:},...
            'StateName',name);
        end

        function dsmsMatchingName=findDSMsWithName(modelName,name)
            searchArgs=autosar.utils.SyncMapping.SearchArgs;
            dsmsMatchingName=find_system(modelName,...
            searchArgs{:},...
            'BlockType','DataStoreMemory',...
            'DataStoreName',name);
        end

        function synthDSMsMatchingName=findSynthesizedDSMsWithName(modelName,name)
            synthDSMsMatchingName={};
            if~isempty(autosar.utils.SyncMapping.findDSMsWithName(modelName,name))

                return;
            end
            searchArgs=autosar.utils.SyncMapping.SearchArgs;
            dataStoreWriteMatchingName=find_system(modelName,...
            searchArgs{:},...
            'BlockType','DataStoreWrite',...
            'DataStoreName',name);
            dataStoreReadMatchingName=find_system(modelName,...
            searchArgs{:},...
            'BlockType','DataStoreRead',...
            'DataStoreName',name);
            synthDSMsMatchingName={dataStoreWriteMatchingName{:},dataStoreReadMatchingName{:}};%#ok<CCAT>
        end

        function isStateflowDSM=isStateflowDataStoreSignal(modelName,name,dsmParents)
            if nargin<3
                dsmParents={};
            end
            isStateflowDSM=false;

            variableUsage=Simulink.findVars(modelName,'Name',name,'SearchMethod','cached');
            if isempty(variableUsage)
                return;
            end

            for usageIdx=1:numel(variableUsage.Users)
                user=variableUsage.Users{usageIdx};

                resolvesToDSM=startsWith(user,dsmParents);
                if Stateflow.SLUtils.isStateflowBlock(user)&&~resolvesToDSM
                    isStateflowDSM=true;
                    return
                end
            end
        end

        function isStateflowSignal=isStateflowSignal(signals)
            isStateflowSignal=arrayfun(@(x)Stateflow.SLUtils.isStateflowBlock(get_param(x,'Parent')),signals);
        end

        function srcPortHandles=getSrcPortHandles(signals)
            if numel(signals)>1
                srcPortHandles=cell2mat(get_param(signals,'SrcPortHandle'));
            else
                srcPortHandles=get_param(signals,'SrcPortHandle');
            end
        end

        function isUnconnected=isSignalUnconnected(signals)
            srcPortHandles=autosar.utils.SyncMapping.getSrcPortHandles(signals);
            isUnconnected=arrayfun(@(x)x==-1,srcPortHandles);
        end

        function resolvesToSignalObject=resolvesToSignalObject(signals)
            srcPortHandles=autosar.utils.SyncMapping.getSrcPortHandles(signals);
            resolvesToSignalObject=strcmp(get_param(srcPortHandles,'MustResolveToSignalObject'),'on');
        end

        function isTestPoint=isTestPointSignal(signals)
            srcPortHandles=autosar.utils.SyncMapping.getSrcPortHandles(signals);
            isTestPoint=strcmp(get_param(srcPortHandles,'TestPoint'),'on');
        end

        function signalMapping=selectPreferredSignalToMap(signalsMatchingName)
            import autosar.utils.SyncMapping

            signalMapping=[];
            signalName=get_param(signalsMatchingName(1),'Name');


            if numel(signalsMatchingName)==1
                signalMapping=signalsMatchingName;
                return;
            end



            resolvesToSignalObIdx=SyncMapping.resolvesToSignalObject(signalsMatchingName);
            signalsResolvingToSignalObjects=signalsMatchingName(resolvesToSignalObIdx);
            if numel(signalsResolvingToSignalObjects)<=1
                signalMapping=signalsResolvingToSignalObjects;
                return;
            else

                signalsMatchingName(~resolvesToSignalObIdx)=[];
            end



            testpointSignalsIdx=SyncMapping.isTestPointSignal(signalsMatchingName);
            if sum(testpointSignalsIdx)<=1
                if any(testpointSignalsIdx)
                    signalMapping=signalsMatchingName(testpointSignalsIdx);
                else
                    signalMapping=signalsMatchingName;
                end
                return;
            else
                autosar.mm.util.MessageReporter.createWarning('autosarstandard:validation:cannotMapMultipleSignalOrState',signalName);
                return;
            end
        end

        function mapping=mappingExistsWithShortName(modelMappings,slMapping,shortName)

            mapping=eval([class(modelMappings),'.empty']);

            for idx=1:numel(modelMappings)
                mappingIter=modelMappings(idx);
                if isa(mappingIter,'Simulink.AutosarTarget.StateMapping')
                    mappedShortName=slMapping.getState(mappingIter.OwnerBlockHandle,mappingIter.Name,'ShortName');
                elseif isa(mappingIter,'Simulink.AutosarTarget.SignalMapping')
                    mappedShortName=slMapping.getSignal(mappingIter.PortHandle,mappingIter.Name,'ShortName');
                elseif isa(mappingIter,'Simulink.AutosarTarget.DataStoreMapping')
                    mappedShortName=slMapping.getDataStore(mappingIter.OwnerBlockHandle,mappingIter.Name,'ShortName');
                elseif isa(mappingIter,'Simulink.AutosarTarget.SynthesizedDataStoreMapping')
                    mappedShortName=slMapping.getSynthesizedDataStore(mappingIter.Name,'ShortName');
                else
                    assert(false,'Unsupported mapping kind');
                end

                if strcmp(mappedShortName,shortName)
                    mapping=mappingIter;
                    return;
                end
            end
        end

        function mappingArgs=getMappingArguments(m3iData,slTypeBuilder)
            m3iType=autosar.utils.SyncMapping.getM3IImpType(m3iData,slTypeBuilder);


            if strcmp(m3iType.MetaClass.qualifiedName,'Simulink.metamodel.types.Structure')
                IsVolatile=m3iType.Elements.at(1).Type.IsVolatile;
                Qualifier=m3iType.Elements.at(1).Type.Qualifier;
            else
                IsVolatile=m3iType.IsVolatile;
                Qualifier=m3iType.Qualifier;
            end


            if IsVolatile
                IsVolatile='true';
            else
                IsVolatile='false';
            end

            if isempty(m3iData.SwAddrMethod)
                swAddrMethodName='';
            else
                swAddrMethodName=m3iData.SwAddrMethod.Name;
            end

            mappingArgs={...
            'ShortName',m3iData.Name,...
            'IsVolatile',IsVolatile,...
            'SwAddrMethod',swAddrMethodName,...
            'DisplayFormat',m3iData.DisplayFormat,...
            'SwCalibrationAccess',m3iData.SwCalibrationAccess.toString,...
            'Qualifier',Qualifier...
            };
        end

        function needsNVRAMAccess=needsNVRAMAccess(m3iComp,pimName)
            needsNVRAMAccess=false;
            m3iSerDeps=m3iComp.Behavior.ServiceDependency;
            for serDepIdx=1:m3iSerDeps.size
                m3iSerDep=m3iSerDeps.at(serDepIdx);
                assert(~isempty(m3iSerDep.UsedDataElement),'Expected UsedDataElement of m3iServiceDependency to be non-empty.');
                if strcmp(m3iSerDep.UsedDataElement.Name,pimName)
                    needsNVRAMAccess=true;
                    return;
                end
            end
        end

        function pimMapping=getMappingWithShortName(modelMappings,slMapping,shortName)

            pimMapping=autosar.utils.SyncMapping.getPimMappingStruct();

            for idx=1:numel(modelMappings)
                mapping=modelMappings(idx);
                if isempty(mapping.Name)
                    continue;
                end
                if isa(mapping,'Simulink.AutosarTarget.StateMapping')
                    mappedShortName=slMapping.getState(mapping.OwnerBlockHandle,mapping.Name,'ShortName');
                    mappingCategory='State';
                elseif isa(mapping,'Simulink.AutosarTarget.SignalMapping')
                    mappedShortName=slMapping.getSignal(mapping.PortHandle,'ShortName');
                    mappingCategory='Signal';
                elseif isa(mapping,'Simulink.AutosarTarget.DataStoreMapping')
                    mappedShortName=slMapping.getDataStore(mapping.OwnerBlockHandle,'ShortName');
                    mappingCategory='DSM';
                elseif isa(mapping,'Simulink.AutosarTarget.SynthesizedDataStoreMapping')
                    mappedShortName=slMapping.getSynthesizedDataStore(mapping.Name,'ShortName');
                    mappingCategory='SynthesizedDSM';
                else
                    assert(false,'Unsupported mapping kind');
                end

                if strcmp(mappedShortName,shortName)
                    pimMapping.mappingCategory=mappingCategory;
                    switch mappingCategory
                    case 'State'

                        pimMapping.mappedSLRef=mapping.OwnerBlockPath;
                    case 'Signal'

                        pimMapping.mappedSLRef=mapping.PortHandle;
                    case 'DSM'

                        pimMapping.mappedSLRef=mapping.OwnerBlockPath;
                    case 'SynthesizedDSM'

                        pimMapping.mappedSLRef=mapping.Name;
                    otherwise
                        assert(false,'Missing PIM mapping category');
                    end
                    return;
                end
            end
        end

        function pimMapping=getPimMappingStruct()
            pimMapping=struct();
            pimMapping.mappingCategory='None';
            pimMapping.mappedSLRef='';
        end
    end
end



