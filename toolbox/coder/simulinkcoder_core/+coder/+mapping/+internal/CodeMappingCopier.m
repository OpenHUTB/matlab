classdef(Abstract)CodeMappingCopier<handle




    properties(Access=protected)
srcMdl
srcSS
srcMdlMappings
dstMdl
dstMdlMappings








subsystemCopyStrategy

srcAlreadyCompiled
inportMappings
localDictionary
    end

    methods(Abstract)
        dstUUID=DstStorageClassUUID(this,srcMdlMapping,dstMdlMapping,uuid);
        dstUUID=DstMemorySectionUUID(this,srcMdlMapping,dstMdlMapping,uuid);
        dstUUID=DstFunctionClassUUID(this,srcMdlMapping,dstMdlMapping,uuid);
    end

    methods(Access=public,Static)

        function mappingType=MappingType(mapping)
            if isempty(mapping)
                mappingType='';
            elseif isa(mapping,'Simulink.CoderDictionary.ModelMapping')
                mappingType="ErtC";
            else
                mappingType="GrtC";
                assert(isa(mapping,'Simulink.CoderDictionary.ModelMappingSLC'))
            end
        end


        function inportMappings=CacheRootInportCodeMappingsForMapping(srcSSInports,srcMdlMapping)
            inportMappings={};
            for idx=1:length(srcSSInports)

                srcSSInport=srcSSInports(idx);
                if strcmp(get_param(srcSSInport,'CompiledPortDataType'),'fcn_call')
                    continue;
                end
                srcSSInportObj=get_param(srcSSInport,'Object');
                if numel(srcSSInportObj)~=1
                    continue;
                end
                srcSSInportActSrcs=srcSSInportObj.getActualSrc;

                if size(srcSSInportActSrcs,1)~=1
                    continue;
                end
                srcSSInportActSrcBlock=get_param(srcSSInportActSrcs(1,1),'ParentHandle');

                if strcmp(get_param(get_param(srcSSInportActSrcBlock,'Parent'),'Type'),'block_diagram')&&...
                    strcmp(get_param(srcSSInportActSrcBlock,'BlockType'),'Inport')
                    actSrcBlockPath=strrep(getfullname(srcSSInportActSrcBlock),newline,' ');
                    inportMappings{end+1}.mapping=srcMdlMapping.Inports.findobj('Block',actSrcBlockPath);%#ok


                else
                    inportMappings{end+1}.mapping=srcMdlMapping.Signals.findobj('PortHandle',srcSSInportActSrcs(1,1));%#ok
                end
            end
        end

    end

    methods(Access=public)
        function this=CodeMappingCopier(srcSS,copyAllMappings)
            this.srcSS=srcSS;
            this.srcMdl=bdroot(srcSS);

            currentMappingType=...
            coder.mapping.internal.CodeMappingCopier.MappingType(...
            Simulink.CodeMapping.getCurrentMapping(this.srcMdl));


            if copyAllMappings||(currentMappingType=="ErtC")
                srcMdlMapping=Simulink.CodeMapping.get(this.srcMdl,'CoderDictionary');
                if~isempty(srcMdlMapping)
                    this.srcMdlMappings{end+1}=srcMdlMapping;
                end
            end


            if copyAllMappings||(currentMappingType=="GrtC")
                srcMdlMapping=Simulink.CodeMapping.get(this.srcMdl,'SimulinkCoderCTarget');
                if~isempty(srcMdlMapping)
                    this.srcMdlMappings{end+1}=srcMdlMapping;
                end
            end
        end


        function CacheRootInportCodeMappings(this)

            if isempty(this.srcMdlMappings)
                return
            end

            oldf=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
            cleanup=onCleanup(@()slfeature('EngineInterface',oldf));

            srcSSPorts=get_param(this.srcSS,'PortHandles');
            srcSSInports=srcSSPorts.Inport;

            for i=1:numel(this.srcMdlMappings)
                this.inportMappings{end+1}=...
                coder.mapping.internal.CodeMappingCopier.CacheRootInportCodeMappingsForMapping(...
                srcSSInports,this.srcMdlMappings{i});
            end
        end

        function ConstructERTCodeMappings(this,dstMdl)
            if isempty(this.srcMdlMappings)
                return
            end

            this.dstMdl=dstMdl;

            for i=1:numel(this.srcMdlMappings)
                srcMdlMapping=this.srcMdlMappings{i};
                if coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC"
                    coder.mapping.internal.create(this.dstMdl,'','MappingType','CoderDictionary');
                    dstMdlMapping=Simulink.CodeMapping.get(this.dstMdl,'CoderDictionary');
                    if~isequal(srcMdlMapping.DeploymentType,'Unset')



                        dstMdlMapping.DeploymentType='Subcomponent';
                    end
                end
            end
        end

        function CopyCodeMappings(this,dstMdl,subsystemCopyStrategy)
            drawnow;





            if isempty(this.srcMdlMappings)
                return
            end

            this.dstMdl=dstMdl;
            this.subsystemCopyStrategy=subsystemCopyStrategy;


            if this.localDictionary
                coder.internal.CoderDataStaticAPI.copyDictionary(this.srcMdl,this.dstMdl);
            end


            for i=1:numel(this.srcMdlMappings)
                srcMdlMapping=this.srcMdlMappings{i};
                if coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC"
                    coder.mapping.internal.create(this.dstMdl,'','MappingType','CoderDictionary');
                    dstMdlMapping=Simulink.CodeMapping.get(this.dstMdl,'CoderDictionary');
                    if~isequal(srcMdlMapping.DeploymentType,'Unset')



                        dstMdlMapping.DeploymentType='Subcomponent';
                    end
                else
                    coder.mapping.internal.create(this.dstMdl,'','MappingType','SimulinkCoderCTarget');
                    dstMdlMapping=Simulink.CodeMapping.get(this.dstMdl,'SimulinkCoderCTarget');
                end
                this.dstMdlMappings{end+1}=dstMdlMapping;
            end


            this.CopyDataAndFunctionDefaultMappings();


            for i=1:numel(this.srcMdlMappings)
                srcMdlMapping=this.srcMdlMappings{i};
                dstMdlMapping=this.dstMdlMappings{i};
                if isa(dstMdlMapping,'Simulink.CoderDictionary.ModelMapping')&&...
                    dstMdlMapping.isFunctionPlatform

                    continue;
                end
                inportMapping=this.inportMappings{i};
                if coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC"

                    this.CopySimulinkFunctionMappings(srcMdlMapping,dstMdlMapping);
                    this.CopySubsystemStepFunctionMapping(dstMdlMapping);
                end

                this.CopyIndividualDataMappings(srcMdlMapping,dstMdlMapping,inportMapping);
            end
        end

    end

    methods(Access=private)

        function CopyDataAndFunctionDefaultMappings(this)
            categories=coder.mapping.internal.dataCategories;
            for ii=1:numel(categories)
                for i=1:numel(this.srcMdlMappings)
                    srcMdlMapping=this.srcMdlMappings{i};
                    dstMdlMapping=this.dstMdlMappings{i};
                    if isa(dstMdlMapping,'Simulink.CoderDictionary.ModelMapping')&&...
                        dstMdlMapping.isFunctionPlatform

                        continue;
                    end
                    this.CopyDefaultStorageClass(categories{ii},srcMdlMapping,dstMdlMapping);
                    if coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC"
                        this.CopyDefaultMemorySection(categories{ii},srcMdlMapping,dstMdlMapping);
                    end
                end
            end
            categories=coder.mapping.internal.functionCategories;
            for ii=1:numel(categories)
                for i=1:numel(this.srcMdlMappings)
                    srcMdlMapping=this.srcMdlMappings{i};
                    dstMdlMapping=this.dstMdlMappings{i};
                    if isa(dstMdlMapping,'Simulink.CoderDictionary.ModelMapping')&&...
                        dstMdlMapping.isFunctionPlatform

                        continue;
                    end
                    if coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC"
                        this.CopyDefaultFunctionClass(categories{ii},srcMdlMapping,dstMdlMapping);
                        this.CopyDefaultMemorySection(categories{ii},srcMdlMapping,dstMdlMapping);
                    end
                end
            end
        end

        function CopyDefaultStorageClass(this,category,srcMdlMapping,dstMdlMapping)
            propName=srcMdlMapping.DefaultsMapping.getPropNameFromType(category);
            srcProp=srcMdlMapping.DefaultsMapping.(propName);
            if isempty(srcProp.StorageClass)
                dstMdlMapping.DefaultsMapping.unset(category,'StorageClass')
            elseif~isempty(srcProp.StorageClass.UUID)
                uuid=this.DstStorageClassUUID(srcMdlMapping,dstMdlMapping,srcProp.StorageClass.UUID);
                if~isempty(uuid)
                    dstMdlMapping.DefaultsMapping.set(category,'StorageClass',uuid);
                    dstProp=dstMdlMapping.DefaultsMapping.(propName);
                    dstProp.CSCAttributes=srcProp.CSCAttributes;
                end
            end
        end

        function CopyDefaultMemorySection(this,category,srcMdlMapping,dstMdlMapping)
            assert(coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC")
            propName=srcMdlMapping.DefaultsMapping.getPropNameFromType(category);
            srcProp=srcMdlMapping.DefaultsMapping.(propName);
            if isempty(srcProp.MemorySection)
                dstMdlMapping.DefaultsMapping.unset(category,'MemorySection');
            elseif~isempty(srcProp.MemorySection.UUID)
                uuid=this.DstMemorySectionUUID(srcMdlMapping,dstMdlMapping,srcProp.MemorySection.UUID);
                if~isempty(uuid)
                    dstMdlMapping.DefaultsMapping.set(category,'MemorySection',uuid);
                end
            end
        end

        function CopyDefaultFunctionClass(this,category,srcMdlMapping,dstMdlMapping)
            assert(coder.mapping.internal.CodeMappingCopier.MappingType(srcMdlMapping)=="ErtC")
            propName=srcMdlMapping.DefaultsMapping.getPropNameFromType(category);
            srcProp=srcMdlMapping.DefaultsMapping.(propName);
            if isempty(srcProp.FunctionClass)
                dstMdlMapping.DefaultsMapping.unset(category,'FunctionClass');
            elseif~isempty(srcProp.FunctionClass.UUID)
                uuid=this.DstFunctionClassUUID(srcMdlMapping,dstMdlMapping,srcProp.FunctionClass.UUID);
                if~isempty(uuid)
                    dstMdlMapping.DefaultsMapping.set(category,'FunctionClass',uuid);
                end
            end
        end

        function CompileSrcModel(this)


            simStatus=get_param(this.srcMdl,'SimulationStatus');
            this.srcAlreadyCompiled=strcmpi(simStatus,'paused')||...
            strcmpi(simStatus,'initializing')||...
            strcmpi(simStatus,'running')||...
            strcmpi(simStatus,'updating');
            if~this.srcAlreadyCompiled
                bdo=get_param(this.srcMdl,'Object');
                init(bdo);
            end
        end

        function UncompileSrcModel(this)
            if~this.srcAlreadyCompiled
                bdo=get_param(this.srcMdl,'Object');
                term(bdo);
            end
        end

        function CopyIndividualDataMappings(this,srcMdlMapping,dstMdlMapping,inportMappings)
            this.CopyParameterMappings(srcMdlMapping,dstMdlMapping);
            this.CopyStateMappings(srcMdlMapping,dstMdlMapping);
            this.CopyDataStoreMappings(srcMdlMapping,dstMdlMapping);
            this.CopySignalMappings(srcMdlMapping,dstMdlMapping);
            this.CopyInportMappings(srcMdlMapping,dstMdlMapping,inportMappings);
        end

        function CopyParameterMappings(this,srcMdlMapping,dstMdlMapping)
            for idx=1:length(dstMdlMapping.ModelScopedParameters)
                dstPrmMapping=dstMdlMapping.ModelScopedParameters(idx);
                paramName=dstPrmMapping.Parameter;
                srcPrmMapping=srcMdlMapping.ModelScopedParameters.findobj('Parameter',paramName);
                this.CopyMapping(srcMdlMapping,dstMdlMapping,srcPrmMapping,dstPrmMapping);
            end
        end

        function CopyStateMappings(this,srcMdlMapping,dstMdlMapping)
            for idx=1:length(dstMdlMapping.States)
                dstStateMapping=dstMdlMapping.States(idx);
                dstBlockPath=dstStateMapping.OwnerBlockPath;
                srcBlockPath=this.SrcBlockPath(dstBlockPath);
                srcStateMapping=srcMdlMapping.States.findobj('OwnerBlockPath',srcBlockPath);
                this.CopyMapping(srcMdlMapping,dstMdlMapping,srcStateMapping,dstStateMapping);
            end
        end

        function CopyDataStoreMappings(this,srcMdlMapping,dstMdlMapping)
            for idx=1:length(dstMdlMapping.DataStores)
                dstDataStoreMapping=dstMdlMapping.DataStores(idx);
                dstBlockPath=dstDataStoreMapping.OwnerBlockPath;
                srcBlockPath=this.SrcBlockPath(dstBlockPath);
                srcDataStoreMapping=srcMdlMapping.DataStores.findobj('OwnerBlockPath',srcBlockPath);
                if isempty(srcDataStoreMapping)
                    pattern=[get_param(this.dstMdl,'Name'),'/_DataStoreBlk_%d'];
                    srcBlockSID=sscanf(dstBlockPath,pattern);
                    if~isempty(srcBlockSID)
                        srcDataStoreMapping=srcMdlMapping.DataStores.findobj('BlockSID',num2str(srcBlockSID));
                    end
                end
                this.CopyMapping(srcMdlMapping,dstMdlMapping,srcDataStoreMapping,dstDataStoreMapping);
            end
        end

        function CopySignalMappings(this,srcMdlMapping,dstMdlMapping)
            for idx=1:length(srcMdlMapping.Signals)
                srcSignalMapping=srcMdlMapping.Signals(idx);
                if isempty(srcSignalMapping.MappedTo)
                    continue;
                end

                srcBlockPath=srcSignalMapping.OwnerBlockPath;
                if~this.InsideSrcSS(srcBlockPath)
                    continue;
                end

                srcPortHandle=srcSignalMapping.PortHandle;
                srcPortNumber=get_param(srcPortHandle,'PortNumber');
                srcSignalMapping=srcMdlMapping.Signals.findobj('PortHandle',srcPortHandle);

                srcMappedTo=srcSignalMapping.MappedTo;

                if~isempty(srcMappedTo.StorageClass)
                    dstBlockPath=this.DstBlockPath(srcBlockPath);

                    if strcmp(get_param(dstBlockPath,'BlockType'),'Inport')
                        dstBlockParent=get_param(dstBlockPath,'Parent');

                        if isequal(dstBlockParent,bdroot(dstBlockParent))
                            dstsignalMapping=dstMdlMapping.Inports.findobj('Block',dstBlockPath);
                        else



                            ph=get_param(dstBlockPath,'PortHandles');
                            dstMdlMapping.addSignal(ph.Outport);
                            dstsignalMapping=dstMdlMapping.Signals.findobj('PortHandle',ph.Outport);
                        end
                    else

                        dstPortHandles=get_param(dstBlockPath,'PortHandles');
                        dstPortHandle=dstPortHandles.Outport(srcPortNumber);
                        dstMdlMapping.addSignal(dstPortHandle);
                        dstsignalMapping=dstMdlMapping.Signals.findobj('PortHandle',dstPortHandle);
                    end
                    this.CopyMapping(srcMdlMapping,dstMdlMapping,srcSignalMapping,dstsignalMapping);
                end
            end
        end

        function CopyInportMappings(this,srcMdlMapping,dstMdlMapping,inportMappings)
            dstMappingIdx=1;
            for idx=1:length(inportMappings)
                dstSrcBlock=find_system(this.dstMdl,'SearchDepth',1,'BlockType','Inport','Port',num2str(idx));



                if strcmp(get_param(dstSrcBlock,'OutputFunctionCall'),'off')
                    srcInportMapping=inportMappings{idx}.mapping;
                    if~isempty(srcInportMapping)
                        dstInportMapping=dstMdlMapping.Inports(dstMappingIdx);
                        this.CopyMapping(srcMdlMapping,dstMdlMapping,srcInportMapping,dstInportMapping);
                    end
                    dstMappingIdx=dstMappingIdx+1;
                end
            end
        end

        function CopySimulinkFunctionMappings(this,srcMdlMapping,dstMdlMapping)
            for idx=1:length(dstMdlMapping.SimulinkFunctionCallerMappings)
                dstSLFcnMapping=dstMdlMapping.SimulinkFunctionCallerMappings(idx);

                srcIdx=find(arrayfun(@(x)isequal(x.SimulinkFunctionName,...
                dstSLFcnMapping.SimulinkFunctionName),...
                srcMdlMapping.SimulinkFunctionCallerMappings));
                if isempty(srcIdx)
                    continue;
                end

                srcSLFcnMapping=srcMdlMapping.SimulinkFunctionCallerMappings(srcIdx);

                if~isempty(srcSLFcnMapping.MappedTo)
                    dstSLFcnMapping.map(srcSLFcnMapping.MappedTo.Prototype);
                end

                if~isempty(srcSLFcnMapping.FunctionReference)
                    if isempty(srcSLFcnMapping.FunctionReference.FunctionClass)
                        dstSLFcnMapping.mapFunctionClass('');
                    elseif~isempty(srcSLFcnMapping.FunctionReference.FunctionClass.UUID)
                        uuid=this.DstFunctionClassUUID(srcMdlMapping,dstMdlMapping,srcSLFcnMapping.FunctionReference.FunctionClass.UUID);
                        dstSLFcnMapping.mapFunctionClass(uuid);
                    end
                    if isempty(srcSLFcnMapping.FunctionReference.MemorySection)
                        dstSLFcnMapping.mapMemorySection('');
                    elseif~isempty(srcSLFcnMapping.FunctionReference.MemorySection.UUID)
                        uuid=this.DstMemorySectionUUID(srcMdlMapping,dstMdlMapping,srcSLFcnMapping.FunctionReference.MemorySection.UUID);
                        dstSLFcnMapping.mapMemorySection(uuid);
                    end
                    if isempty(srcSLFcnMapping.FunctionReference.InternalDataMemorySection)
                        dstSLFcnMapping.mapInternalDataMemorySection('');
                    elseif~isempty(srcSLFcnMapping.FunctionReference.InternalDataMemorySection.UUID)
                        uuid=this.DstMemorySectionUUID(srcMdlMapping,dstMdlMapping,srcSLFcnMapping.FunctionReference.InternalDataMemorySection.UUID);
                        dstSLFcnMapping.mapInternalDataMemorySection(uuid);
                    end
                end
            end

        end

        function CopySubsystemStepFunctionMapping(this,dstMdlMapping)
            fcnprotoConf=get_param(this.srcSS,'SSRTWFcnClass');
            if~isempty(fcnprotoConf)
                if isa(fcnprotoConf,'RTW.ModelSpecificCPrototype')&&...
                    get_param(this.srcMdl,'versionloaded')<=7.1
                    if isempty(fcnprotoConf.InitFunctionName)
                        fcnprotoConf.InitFunctionName=[get_param(this.srcMdl,'name'),'_initialize'];
                    end
                end
                if isempty(dstMdlMapping.OutputFunctionMappings)




                    dstMdlMapping.addOutputFunctionMapping()
                end
                set_param(this.dstMdl,'RTWFcnClass',fcnprotoConf)
            end
        end

        function srcBlockPath=SrcBlockPath(this,dstBlockPath)
            dstModel=get_param(this.dstMdl,'Name');
            if this.subsystemCopyStrategy==Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Content
                srcBlockPath=[getfullname(this.srcSS),dstBlockPath(numel(dstModel)+1:end)];
            elseif this.subsystemCopyStrategy==Simulink.ModelReference.Conversion.SubsystemCopyStrategy.BlockWithBEPs
                ssName=get_param(getfullname(this.srcSS),'Name');
                srcBlockPath=[getfullname(this.srcSS),dstBlockPath(numel(dstModel)+1+numel(ssName)+1:end)];
            else
                srcBlockPath=[get_param(this.srcSS,'Parent'),dstBlockPath(numel(dstModel)+1:end)];
            end
            srcBlockPath=strrep(srcBlockPath,newline,' ');
        end

        function dstBlockPath=DstBlockPath(this,srcBlockPath)
            srcSSName=getfullname(this.srcSS);
            if this.subsystemCopyStrategy==Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Content
                dstBlockPath=[get_param(this.dstMdl,'Name'),srcBlockPath(numel(srcSSName)+1:end)];
            elseif this.subsystemCopyStrategy==Simulink.ModelReference.Conversion.SubsystemCopyStrategy.BlockWithBEPs
                ssName=get_param(srcSSName,'Name');
                ssName=replace(ssName,'/','//');
                dstBlockPath=[get_param(this.dstMdl,'Name'),'/',ssName,srcBlockPath(numel(srcSSName)+1:end)];
            else
                dstSS=get_param(this.dstMdl,'NewSubsystemHdlForRightClickBuild');
                if dstSS==0
                    assert(slfeature('RightClickBuild')==1);
                    ssName=get_param(srcSSName,'Name');
                    ssName=replace(ssName,'/','//');
                    dstBlockPath=[get_param(this.dstMdl,'Name'),'/',ssName,srcBlockPath(numel(srcSSName)+1:end)];
                else
                    dstBlockPath=[getfullname(dstSS),srcBlockPath(numel(srcSSName)+1:end)];
                end

            end
            dstBlockPath=strrep(dstBlockPath,newline,' ');
        end


        function CopyMapping(this,srcMdlMapping,dstMdlMapping,srcMapping,dstMapping)
            if~isempty(srcMapping)&&~isempty(srcMapping.MappedTo)
                srcMappedTo=srcMapping.MappedTo;

                if~isempty(srcMappedTo.StorageClass)

                    if isempty(srcMappedTo.StorageClass.UUID)
                        dstMapping.map('');
                    else
                        uuid=this.DstStorageClassUUID(srcMdlMapping,dstMdlMapping,srcMappedTo.StorageClass.UUID);
                        if~isempty(uuid)
                            dstMapping.map(uuid);
                            dstMapping.MappedTo.CSCAttributes=srcMappedTo.CSCAttributes;
                        end
                    end
                    dstMapping.MappedTo.Identifier=srcMappedTo.Identifier;
                end
            end
        end

        function inside=InsideSrcSS(this,srcBlockPath)
            parent=get_param(get_param(srcBlockPath,'Parent'),'Handle');
            if parent==this.srcSS
                inside=true;
            elseif strcmp(get_param(parent,'Type'),'block_diagram')
                inside=false;
            else
                inside=this.InsideSrcSS(parent);
            end
        end

    end
end


