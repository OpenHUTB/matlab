classdef Builder<autosar.composition.utils.SLCompositionVisitor





    properties(SetAccess=immutable,GetAccess=private)
        RootModelName;
        SystemPathToExport;
        ExportedArxmlFolder;
        OkayToPushNags;
        PackageCodeAndArxml;
        ExportECUExtract;
        Packager;
        RootM3IModel;

        ExportClientServerConnectors;
        ExportIsServicePortConnectors;





        CompModelsInfo;



        AllInterfaceDicts;





        AggregateSharedElements;
    end

    properties(Access=private)
        CompBlocksWithNoModels;
        FirstComponentModelConfigSet;
        SharedElementsCopier;
    end

    methods
        function this=Builder(systemPath,varargin)

            doVisitSubCompositions=true;
            rootModelName=get_param(bdroot(systemPath),'Name');
            this@autosar.composition.utils.SLCompositionVisitor(...
            rootModelName,doVisitSubCompositions);


            p=inputParser;
            p.addParameter('ExportedArxmlFolder',pwd,@(x)(ischar(x)||isStringScalar(x)));
            p.addParameter('CompModelsInfo',[]);
            p.addParameter('ZipFileName','',@(x)(ischar(x)||isStringScalar(x)));
            p.addParameter('OkayToPushNags',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.addParameter('ExportClientServerConnectors',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.addParameter('ExportIsServicePortConnectors',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.addParameter('ExportECUExtract',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.parse(varargin{:});


            this.RootModelName=rootModelName;
            this.SystemPathToExport=getfullname(systemPath);
            this.OkayToPushNags=p.Results.OkayToPushNags;
            this.ExportedArxmlFolder=p.Results.ExportedArxmlFolder;
            this.ExportClientServerConnectors=p.Results.ExportClientServerConnectors;
            this.ExportIsServicePortConnectors=p.Results.ExportIsServicePortConnectors;
            this.ExportECUExtract=p.Results.ExportECUExtract;
            this.RootM3IModel=autosar.api.Utils.m3iModel(this.RootModelName);
            this.CompModelsInfo=p.Results.CompModelsInfo;
            this.AllInterfaceDicts=this.findAllInterfaceDictUsedByHierarchy();
            this.AggregateSharedElements=this.shouldAggregateSharedElements();


            this.createCompositionArxmlFolder(p.Results.ExportedArxmlFolder);
            this.PackageCodeAndArxml=~isempty(p.Results.ZipFileName);

            if this.PackageCodeAndArxml




                if~this.AggregateSharedElements
                    assert(numel(this.AllInterfaceDicts)==1,...
                    'Expected model to be linked to a single interface dictionary.');
                    interfaceDict=autosar.utils.File.dropPath(...
                    this.AllInterfaceDicts{1},DropExtension=true);
                    [basePath,~,~]=fileparts(this.ExportedArxmlFolder);
                    dictionaryFolders={fullfile(basePath,interfaceDict)};
                else
                    dictionaryFolders={};
                end
                this.Packager=autosar.composition.build.Packager(...
                this.ExportedArxmlFolder,p.Results.ZipFileName,dictionaryFolders);
            end
        end


        function build(this)



            compDstPkg=autosar.mm.util.XmlOptionsAdapter.get(this.RootM3IModel.RootPackage.front,'ComponentPackage');
            m3iElmMover=autosar.composition.utils.M3IElementMover(this.RootModelName);
            m3iElmMover.moveMappedComponent(compDstPkg);




            origDirtyFlag=get_param(this.RootModelName,'Dirty');
            restoreDirtyFlag=onCleanup(@()set_param(this.RootModelName,...
            'Dirty',origDirtyFlag));


            t=M3I.Transaction(this.RootM3IModel);


            this.prepareRootArchitectureModel();

            if this.isSingleComponentBuild()
                this.buildForComponent();
            else
                assert(~isempty(this.CompModelsInfo),...
                'CompModelsInfo should not be empty for composition builds');
                this.buildForComposition();
            end

            if this.ExportECUExtract


                t.cancel();
            else
                t.commit();
            end
        end
    end

    methods(Access=private)
        function buildForComponent(this)

            [~,componentMdlToBuild]=autosar.composition.Utils.isCompBlockLinked(this.SystemPathToExport);
            if~bdIsLoaded(componentMdlToBuild)
                load_system(componentMdlToBuild);
            end

            visitInfo=struct(...
            'NumElmsToVisit',1,...
            'CurrentElmIdx',1);
            this.visitComponent(componentMdlToBuild,visitInfo);
        end

        function buildForComposition(this)



            this.visitCompBlocks(this.SystemPathToExport);


            this.visitComponents(this.SystemPathToExport);


            this.visitInterfaceDicts();


            this.visitCompositions(this.SystemPathToExport);
        end
    end

    methods(Access=protected)

        function visitCompBlock(this,compBlk)




            m3iCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(compBlk);
            m3iDesc=autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(...
            this.RootM3IModel,m3iCompProto.desc,get_param(compBlk,'Description'));
            if~isempty(m3iDesc)
                m3iCompProto.desc=m3iDesc;
            end
        end

        function visitComponent(this,componentSys,visitInfo)


            if strcmp(get_param(componentSys,'type'),'block_diagram')
                componentModel=componentSys;
                this.buildComponentModel(componentModel,visitInfo);
            else
                componentBlock=componentSys;
                this.processCompBlockWithNoModel(componentBlock,visitInfo);
            end
        end

        function visitComposition(this,compositionSys,visitInfo)





            this.addCompositionConnectors(compositionSys);

            isTopComposition=this.isTopComposition(compositionSys);
            if isTopComposition
                this.createECUExtract();

                isRootCompostition=this.isRootComposition(compositionSys);
                if isRootCompostition
                    removeM3ICrossRefCleanup=this.updateOrCreateExecutionOrderConstraints();%#ok
                end


                m3iObj=autosar.composition.Utils.findM3IObjectForCompositionElement(compositionSys);
                if isa(m3iObj,'Simulink.metamodel.arplatform.composition.ComponentPrototype')
                    m3iCompType=m3iObj.Type;
                else
                    assert(isa(m3iObj,'Simulink.metamodel.arplatform.component.Component'));
                    m3iCompType=m3iObj;
                end
                m3iDesc=autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(...
                this.RootM3IModel,m3iCompType.desc,get_param(compositionSys,'Description'));
                if~isempty(m3iDesc)
                    m3iCompType.desc=m3iDesc;
                end


                this.exportTopComposition();
            else

                this.processCompBlockWithNoModel(compositionSys,visitInfo);
            end
        end
    end

    methods(Access=private)
        function isRoot=isRootComposition(this,compositionSys)
            isRoot=strcmp(this.RootModelName,compositionSys);
        end

        function isTop=isTopComposition(this,compositionSys)
            isTop=strcmp(this.SystemPathToExport,compositionSys);
        end

        function visitInterfaceDicts(this)









            configSetOfBuildContext=this.FirstComponentModelConfigSet;
            if isempty(configSetOfBuildContext)
                configSetOfBuildContext=getActiveConfigSet(this.RootModelName);
            end

            dicts=autosar.utils.File.dropPath(this.AllInterfaceDicts);
            rootModelSchemaVer=get_param(this.RootModelName,'AutosarSchemaVersion');
            for idx=1:length(dicts)
                disp(' ');
                dict=dicts{idx};
                interfaceDict=Simulink.interface.dictionary.open(dict);
                platformAPI=interfaceDict.getPlatformMapping('AUTOSARClassic');
                arProps=autosar.api.getAUTOSARProperties(dict);
                dictM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(dict);



                if strcmp(arProps.get('XmlOptions','XmlOptionsSource'),'Inherit')
                    dictSchemaVer=autosar.ui.utils.getAutosarSchemaVersion(dictM3IModel);
                    if~strcmp(dictSchemaVer,rootModelSchemaVer)
                        tran=autosar.utils.M3ITransaction(dictM3IModel,DisableListeners=true);
                        m3iModelContext=autosar.api.internal.M3IModelContext.createContext(dict);
                        autosar.api.getAUTOSARProperties.setXmlOptionProperty(dictM3IModel.RootPackage.front,...
                        'SchemaVersion',rootModelSchemaVer,'None',m3iModelContext);
                        tran.commit();
                    end
                end

                [~,n,e]=fileparts(dict);
                dictName=[n,e];
                msg=DAStudio.message('autosarstandard:exporter:MessageViewer_ExportingDictionaryStage',...
                dictName,num2str(idx),num2str(length(dicts)));
                stage=this.dispStageInContext(msg);%#ok<NASGU>
                platformAPI.exportDictionary(IsArchModelUIContext=this.OkayToPushNags,...
                ConfigSetOfBuildContext=configSetOfBuildContext);

                if this.AggregateSharedElements
                    this.SharedElementsCopier.copySharedElementsFromInterfaceDict(dict);
                end
            end
        end

        function removeM3ICrossRefCleanup=updateOrCreateExecutionOrderConstraints(this)
            m3iComposition=getM3IComposition(this);
            vfbViewBuilder=autosar.timing.sl2mm.VfbViewBuilder(this.RootModelName,m3iComposition);
            vfbViewBuilder.build();

            removeM3ICrossRefCleanup=onCleanup(@()vfbViewBuilder.removeM3iCrossReferences());
        end

        function createECUExtract(this)




            if~this.ExportECUExtract
                return
            end


            m3iComposition=getM3IComposition(this);
            maxShortNameLength=get_param(this.RootModelName,'AutosarMaxShortNameLength');
            flattenCompositionBuilder=autosar.system.sl2mm.FlattenCompositionBuilder(...
            m3iComposition,maxShortNameLength,this.SystemPathToExport);
            flattenCompositionBuilder.build();


            ecuExtractBuilder=autosar.system.sl2mm.EcuExtractBuilder(...
            this.RootModelName,m3iComposition,this.SystemPathToExport);
            ecuExtractBuilder.build();




            this.CompBlocksWithNoModels=[];
        end

        function m3iComposition=getM3IComposition(this)

            isRootCompostition=strcmp(this.SystemPathToExport,this.RootModelName);
            if isRootCompostition
                m3iComposition=autosar.api.Utils.m3iMappedComponent(this.RootModelName);
            else
                m3iCompPrototype=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(...
                this.SystemPathToExport);
                m3iComposition=m3iCompPrototype.Type;
            end
        end

        function buildComponentModel(this,componentModel,visitInfo)


            this.preComponentBuild(componentModel,visitInfo);


            this.doBuildComponentModel(componentModel);


            this.postComponentBuild(componentModel);
        end

        function exportTopComposition(this)
            disp(' ');
            msg=DAStudio.message('autosarstandard:exporter:MessageViewer_ExportingCompositionStage',...
            this.SystemPathToExport);
            exportCompositionStage=this.dispStageInContext(msg);%#ok<NASGU>


            this.doExportTopComposition();


            if this.PackageCodeAndArxml
                this.Packager.createFinalCompositionPackage();
            end


            msg=DAStudio.message('autosarstandard:exporter:MessageViewer_ExportCompositionSuccessMessage',...
            this.SystemPathToExport);
            Simulink.output.info(msg);
        end

        function addCompositionConnectors(this,compositionSys)



            this.destroyDerivedCompositionPorts(compositionSys);


            rootModelInfo=this.CompModelsInfo(this.RootModelName);
            connectorBuilder=autosar.composition.sl2mm.ConnectorBuilder(compositionSys,...
            rootModelInfo.AllDictsInterfaceNames);
            connectorBuilder.build();
        end

        function processCompBlockWithNoModel(this,compBlock,visitInfo)
            if autosar.composition.Utils.isComponentBlock(compBlock)

                disp(' ');
                msg=DAStudio.message('autosarstandard:exporter:MessageViewer_BuildingComponentModelStage',...
                compBlock,visitInfo.CurrentElmIdx,visitInfo.NumElmsToVisit);
                buildCompModelStage=this.dispStageInContext(msg);%#ok<NASGU>


                msg2=DAStudio.message('autosarstandard:exporter:MessageViewer_ComponentBlockNoImplementation',...
                compBlock);
                Simulink.output.info(msg2);
            end


            this.CompBlocksWithNoModels{end+1}=compBlock;
        end

        function preComponentBuild(this,componentModel,visitInfo)

            disp(' ');
            msg=DAStudio.message('autosarstandard:exporter:MessageViewer_BuildingComponentModelStage',...
            componentModel,visitInfo.CurrentElmIdx,visitInfo.NumElmsToVisit);
            buildCompModelStage=this.dispStageInContext(msg);%#ok<NASGU>


            arProps=autosar.api.getAUTOSARProperties(componentModel);
            if strcmp(arProps.get('XmlOptions','XmlOptionsSource'),'Inherit')



                dstPkg=autosar.mm.util.XmlOptionsAdapter.get(this.RootM3IModel.RootPackage.front,'ComponentPackage');
                m3iElmMover=autosar.composition.utils.M3IElementMover(componentModel);
                m3iElmMover.moveMappedComponent(dstPkg);




                origDirtyFlag=get_param(componentModel,'Dirty');
                restoreDirtyFlag=onCleanup(@()set_param(componentModel,...
                'Dirty',origDirtyFlag));



                targetM3IModel=autosar.api.Utils.m3iModel(componentModel);
                if autosar.dictionary.Utils.hasReferencedModels(targetM3IModel)
                    targetM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(targetM3IModel);
                end

                tran=autosar.utils.M3ITransaction(targetM3IModel,DisableListeners=true);
                autosar.composition.utils.XmlOptionsCopier.copyXmlOptionsAndSetToInherit(...
                this.RootM3IModel,targetM3IModel);



                m3iElmMover.moveElementsToMatchXmlOptions();
                tran.commit();
            end
        end

        function doBuildComponentModel(this,componentModel)



            resetCompBuildParam=onCleanup(@()set_param(componentModel,...
            'IsComponentBuildFromComposition','off'));
            set_param(componentModel,'IsComponentBuildFromComposition','on');


            sl('slbuild_private',componentModel,'StandaloneCoderTarget',...
            'OkayToPushNags',this.OkayToPushNags,...
            'LaunchCodeGenerationReport',false);

            if isempty(this.FirstComponentModelConfigSet)
                this.FirstComponentModelConfigSet=getActiveConfigSet(componentModel);
            end

            if~(strcmp(get_param(this.SystemPathToExport,'type'),'block')&&...
                autosar.composition.Utils.isComponentBlock(this.SystemPathToExport))


                autosar.composition.build.Builder.exportComponentDescription(...
                componentModel,this.ExportedArxmlFolder);
            end
        end

        function postComponentBuild(this,componentModel)


            if this.AggregateSharedElements
                this.SharedElementsCopier.copySharedElementsFromComp(componentModel);
            end


            if this.PackageCodeAndArxml
                this.Packager.packageComponentModel(componentModel);
            end
        end

        function doExportTopComposition(this)

            msg=DAStudio.message('autosarstandard:exporter:MessageViewer_GeneratingXMLFiles',...
            this.SystemPathToExport);
            Simulink.output.info(msg);





            compositionModelCompile=...
            autosar.validation.CompiledModelUtils.forceCompiledModel(this.RootModelName);




            elmQNameToFileMap=containers.Map();
            for i=1:length(this.CompBlocksWithNoModels)
                compBlock=this.CompBlocksWithNoModels{i};
                m3iComp=autosar.composition.studio.CompBlockUtils.getM3IComp(compBlock);
                compQName=autosar.api.Utils.getQualifiedName(m3iComp);
                if isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')
                    elmQNameToFileMap(compQName)=...
                    autosar.mm.arxml.Exporter.getCompositionArxmlFileName(m3iComp.Name,true);
                else
                    elmQNameToFileMap(compQName)=...
                    autosar.mm.arxml.Exporter.getComponentArxmlFileName(m3iComp.Name,true);
                end
            end


            m3iComposition=this.getM3IComposition();
            assert(isa(m3iComposition,'Simulink.metamodel.arplatform.composition.CompositionComponent'),...
            'unexpected composition type!');
            compositionQName=autosar.api.Utils.getQualifiedName(m3iComposition);
            arxmlPrefix=get_param(this.SystemPathToExport,'Name');
            elmQNameToFileMap(compositionQName)=...
            autosar.mm.arxml.Exporter.getCompositionArxmlFileName(arxmlPrefix,true);


            arRoot=m3iComposition.rootModel.RootPackage.front();
            arRoot.ArxmlFilePackaging=Simulink.metamodel.arplatform.common.ArxmlFilePackagingKind.Modular;


            autosar.mm.arxml.Exporter.exportModel(this.RootModelName,...
            'ElmQNameToFileMap',elmQNameToFileMap,...
            'ExportedArxmlFolder',this.ExportedArxmlFolder);


            interfaceDicts=autosar.utils.File.dropPath(this.AllInterfaceDicts,DropExtension=true);
            if~this.AggregateSharedElements
                for dictIdx=1:numel(interfaceDicts)
                    dictionaryName=interfaceDicts{dictIdx};
                    dictFolder=fullfile(Simulink.fileGenControl('getConfig').CodeGenFolder,dictionaryName);
                    dictionaryArxmlFiles=autosar.composition.build.Packager.findFilesWithExtension(dictFolder,'.arxml');
                    cellfun(@(x)copyfile(x,this.ExportedArxmlFolder),dictionaryArxmlFiles);
                end
            end


            stubFolder=fullfile(this.ExportedArxmlFolder,autosar.mm.arxml.Exporter.StubFolderName);
            if exist(stubFolder,'dir')
                children=dir(stubFolder);
                children=children(~ismember({children.name},{'.','..'}));
                if isempty(children)
                    rmdir(stubFolder);
                end
            end


            compositionModelCompile.delete();
        end


        function createCompositionArxmlFolder(this,arxmlFolder)%#ok<INUSL>
            if isempty(arxmlFolder)

                return;
            end


            rtw_checkdir(arxmlFolder);

            if isfolder(arxmlFolder)

                arxmlFiles=autosar.composition.build.Packager.findFilesWithExtension(arxmlFolder,'.arxml');
                cellfun(@(x)delete(x),arxmlFiles);
            else

                [status,msg,msgId]=mkdir(arxmlFolder);
                if~status
                    error(msgId,'%s',msg);
                end
            end



            stubFolder=fullfile(arxmlFolder,autosar.mm.arxml.Exporter.StubFolderName);
            if~isfolder(stubFolder)
                [status,msg,msgId]=mkdir(stubFolder);
                if~status
                    error(msgId,'%s',msg);
                end
            end
        end

        function terminateStage=dispStageInContext(this,msg)
            if this.OkayToPushNags

                terminateStage=sldiagviewer.createStage(msg,'ModelName',this.RootModelName);
            else
                terminateStage=[];
                disp(msg);
            end
            set_param(this.RootModelName,'StatusString',msg);
        end



        function destroyDerivedCompositionPorts(this,compositionSys)
            isRootComposition=this.isRootComposition(compositionSys);
            if isRootComposition
                m3iComposition=autosar.api.Utils.m3iMappedComponent(compositionSys);
            else
                m3iComposition=autosar.composition.studio.CompBlockUtils.getM3IComp(compositionSys);
            end

            m3iClientPorts=m3iComposition.ClientPorts;
            while(~m3iClientPorts.isEmpty())
                m3iClientPorts.front.destroy();
            end

            m3iServerPorts=m3iComposition.ServerPorts;
            while(~m3iServerPorts.isEmpty())
                m3iServerPorts.front.destroy();
            end




            m3iPorts=autosar.mm.Model.findObjectByMetaClass(m3iComposition,...
            Simulink.metamodel.arplatform.port.Port.MetaClass,true,true);
            m3iPortNames=m3i.mapcell(@(x)x.Name,m3iPorts);
            graphicalBusPorts=find_system(compositionSys,'SearchDepth',1,...
            'IsBusElementPort','on');
            graphicalBusPortNames=[];
            if~isempty(graphicalBusPorts)
                graphicalBusPortNames=get_param(graphicalBusPorts,'PortName');
            end
            [~,indicesToRemove]=setdiff(m3iPortNames,graphicalBusPortNames);
            indicesToRemove=sort(indicesToRemove,'descend');
            for idxRem=1:length(indicesToRemove)
                m3iPorts.at(indicesToRemove(idxRem)).destroy();
            end
        end

        function destroySharedPackagedElements(this)






            m3iObjSeq=autosar.composition.build.SharedElementsCopier.findSharedPackagedElements(this.RootM3IModel);
            for i=1:m3iObjSeq.size()
                m3iObj=m3iObjSeq.at(i);
                if m3iObj.isvalid()&&~autosar.dictionary.Utils.isSharedM3IModel(m3iObj.rootModel)
                    m3iObj.destroy();
                end
            end
        end


        function prepareRootArchitectureModel(this)
            import autosar.mm.util.XmlOptionsDefaultPackages





            this.destroySharedPackagedElements();



            this.SharedElementsCopier=autosar.composition.build.SharedElementsCopier(this.SystemPathToExport);


            autosar.composition.sl2mm.ConnectorBuilder.destroyM3IConnectors(this.RootM3IModel);





            XmlOptionsDefaultPackages.setAllEmptyXmlOptionsToDefault(this.RootModelName);



            compDstPkg=autosar.mm.util.XmlOptionsAdapter.get(this.RootM3IModel.RootPackage.front,'ComponentPackage');
            autosar.composition.utils.M3IElementMover.moveElementsByMetaClass(...
            Simulink.metamodel.arplatform.component.Component.MetaClass,...
            compDstPkg,this.RootM3IModel);
        end

        function tf=isSingleComponentBuild(this)


            tf=strcmp(get_param(this.SystemPathToExport,'type'),'block')&&...
            autosar.composition.Utils.isComponentBlock(this.SystemPathToExport);
        end

        function shouldAggregate=shouldAggregateSharedElements(this)






            shouldAggregate=false;

            if this.isSingleComponentBuild()
                shouldAggregate=isempty(this.AllInterfaceDicts);
                return;
            end

            modelsToExport=this.CompModelsInfo.keys();

            info=this.CompModelsInfo(modelsToExport{1});
            firstModelInterfacesDicts=unique(info.ReferencedInterfaceDicts);

            if isempty(firstModelInterfacesDicts)||numel(firstModelInterfacesDicts)>1
                shouldAggregate=true;
                return;
            end

            for idx=2:length(modelsToExport)
                modelName=modelsToExport{idx};
                info=this.CompModelsInfo(modelName);
                interfacesDicts=unique(info.ReferencedInterfaceDicts);
                if isempty(interfacesDicts)||(numel(interfacesDicts)>1)||...
                    ~isequal(interfacesDicts,firstModelInterfacesDicts)
                    shouldAggregate=true;
                    return;
                end
            end
        end

        function allInterfaceDicts=findAllInterfaceDictUsedByHierarchy(this)


            if this.isSingleComponentBuild()
                componentMdl=get_param(this.SystemPathToExport,'ModelName');
                load_system(componentMdl);
                allInterfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(componentMdl);
            else
                modelsToExport=this.CompModelsInfo.keys();
                allInterfaceDicts={};
                for idx=1:length(modelsToExport)
                    modelName=modelsToExport{idx};
                    info=this.CompModelsInfo(modelName);
                    interfacesDicts=unique(info.ReferencedInterfaceDicts);
                    if~isempty(interfacesDicts)
                        allInterfaceDicts=[allInterfaceDicts,interfacesDicts];%#ok<AGROW>
                    end
                end
                allInterfaceDicts=unique(allInterfaceDicts);
            end
        end
    end

    methods(Static,Access=private)
        function exportComponentDescription(componentModel,arxmlFolder)




            m3iComponent=autosar.api.Utils.m3iMappedComponent(componentModel);
            m3iSeqOfPackagedElmsToWrite=M3I.SequenceOfClassObject.make(m3iComponent.rootModel);
            m3iSeqOfPackagedElmsToWrite.append(m3iComponent);
            componentQName=autosar.api.Utils.getQualifiedName(m3iComponent);


            arxmlFileName=autosar.mm.arxml.Exporter.getComponentArxmlFileName(componentModel,true);
            elmQNameToFileMap=containers.Map(componentQName,arxmlFileName);


            modelCompile=autosar.validation.CompiledModelUtils.forceCompiledModel(componentModel);



            bDir=RTW.getBuildDir(componentModel).BuildDirectory;
            bi=load(fullfile(bDir,'buildInfo.mat'));


            m3iModel=autosar.api.Utils.m3iModel(componentModel);
            m3iTimingModel=autosar.timing.Utils.findM3iTimingForM3iComponent(m3iModel,m3iComponent);
            if~isempty(m3iTimingModel)

                m3iSeqOfPackagedElmsToWrite.append(m3iTimingModel);
                timingArxmlFileName=autosar.mm.arxml.Exporter.getTimingExtensionArxmlFileName(componentModel,true);
                timingQName=autosar.api.Utils.getQualifiedName(m3iTimingModel);
                elmQNameToFileMap(timingQName)=timingArxmlFileName;
            end



            [~,lGenSettings]=coder.internal.getSTFInfo(componentModel);
            cleanupGenSettingsCache=coder.internal.infoMATFileMgr...
            ([],[],[],[],...
            'InitializeGenSettings',lGenSettings);%#ok<NASGU>


            autosar.mm.arxml.Exporter.exportPackagedElements(componentModel,...
            m3iSeqOfPackagedElmsToWrite,elmQNameToFileMap,arxmlFolder,bi.buildInfo);

            modelCompile.delete();
        end
    end
end



