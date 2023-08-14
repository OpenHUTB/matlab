classdef SimulinkListener<handle






    methods(Static)


        function blockAdded(blkH,copiedFromBlkH,compKindHint)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                if autosar.composition.studio.SimulinkListener.isComponentBlockAdded(...
                    blkH,copiedFromBlkH,compKindHint)
                    autosar.composition.studio.SimulinkListener.componentBlockAdded(...
                    blkH,copiedFromBlkH,compKindHint);
                elseif autosar.composition.studio.SimulinkListener.isCompositionBlockAdded(...
                    blkH,copiedFromBlkH,compKindHint)
                    autosar.composition.studio.SimulinkListener.compositionBlockAdded(...
                    blkH,copiedFromBlkH);
                elseif autosar.composition.Utils.isCompositePortBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compositePortBlockAdded(...
                    blkH,copiedFromBlkH);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end



        function blockRemoved(blkH)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                if autosar.composition.Utils.isComponentBlock(blkH)
                    autosar.composition.studio.SimulinkListener.componentBlockRemoved(blkH);
                elseif autosar.composition.Utils.isCompositionBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compositionBlockRemoved(blkH);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end



        function compositePortBlockRemoved(blkH,portName)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>
                autosar.composition.studio.SimulinkListener.arPortRemoved(blkH,portName);
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end



        function blockCheckParamChange(blkH,paramName,newValue)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                if autosar.composition.Utils.isComponentBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compBlockCheckParamChange(...
                    blkH,paramName,newValue);
                elseif autosar.composition.Utils.isCompositionBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compBlockCheckParamChange(...
                    blkH,paramName,newValue);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end



        function blockParamChanged(blkH,paramName,oldValue,newValue)
            try

                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                if autosar.composition.Utils.isComponentBlock(blkH)
                    autosar.composition.studio.SimulinkListener.componentBlockParamChanged(...
                    blkH,paramName,oldValue,newValue);
                elseif autosar.composition.Utils.isCompositionBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compositionBlockParamChanged(...
                    blkH,paramName,oldValue,newValue);
                elseif autosar.composition.Utils.isCompositePortBlock(blkH)
                    autosar.composition.studio.SimulinkListener.compositePortBlockParamChanged(...
                    blkH,paramName,oldValue,newValue);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function modelParamChanged(modelH,paramName)


            import Simulink.interface.dictionary.internal.DictionaryClosureUtils

            try
                switch paramName
                case 'SystemTargetFile'



                    isAUTOSARCompliant=strcmp(get_param(modelH,'AutosarCompliant'),'on');
                    isAdaptiveTarget=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelH);
                    if~isAUTOSARCompliant||...
                        (~slfeature('AdaptiveArchitectureModeling')&&isAdaptiveTarget)



                        faultySTF=get_param(modelH,'SystemTargetFile');
                        DAStudio.warning('autosarstandard:editor:ArchModelNonCompliantSTF',faultySTF);
                        set_param(modelH,'SystemTargetFile','autosar.tlc');
                    end
                case 'DataDictionary'
                    [isLinkedToInterfaceDict,dictFiles]=DictionaryClosureUtils.isModelLinkedToInterfaceDict(modelH);
                    m3iModelComposition=autosar.api.Utils.m3iModel(modelH);
                    if isLinkedToInterfaceDict
                        for idx=1:numel(dictFiles)
                            dictFile=dictFiles{idx};
                            interfaceDictAPI=Simulink.interface.dictionary.open(dictFile);


                            if~interfaceDictAPI.hasPlatformMapping('AUTOSARClassic')
                                interfaceDictAPI.addPlatformMapping('AUTOSARClassic');
                            end


                            interfaceDictFileName=interfaceDictAPI.DictionaryFileName;
                            m3iModelDict=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(interfaceDictAPI.filepath());
                            autosar.dictionary.Utils.updateModelMappingWithDictionary(modelH,interfaceDictFileName);
                            Simulink.AutosarDictionary.ModelRegistry.addReferencedModel(m3iModelComposition,m3iModelDict);
                        end
                    else

                        if~isempty(autosarcore.ModelUtils.getMappingSharedDictUUID(modelH))
                            autosar.dictionary.internal.LinkUtils.unlinkModelFromInterfaceDictionary(...
                            modelH,m3iModelComposition);
                        end
                    end
                otherwise
                    assert(false,'Should not be listening to changes to parameter:%s',paramName);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function registerM3IModelListener(modelName)
            m3iModel=autosar.api.Utils.m3iModel(modelName);


            tran=M3I.Transaction(m3iModel);
            arRoot=m3iModel.RootPackage.front;
            arRoot.setExternalToolInfo(M3I.ExternalToolInfo('M3IModelForArchitectureModel','1'));
            tran.commit;


            autosar.ui.utils.registerListenerCB(m3iModel);
        end



        function anyUsing=anyComponentPrototypesUsingCompType(m3iModel,m3iCompType,excludeCompProto)
            anyUsing=false;
            if nargin<3
                excludeCompProto=[];
            end

            m3iAllCompProtos=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.composition.ComponentPrototype.MetaClass,true);
            for i=1:m3iAllCompProtos.size()
                m3iCompProto=m3iAllCompProtos.at(i);
                if~isempty(excludeCompProto)&&(excludeCompProto==m3iCompProto)
                    continue;
                end
                if m3iCompProto.Type==m3iCompType
                    anyUsing=true;
                    return;
                end
            end
        end


        function m3iComponent=getOrAddComponent(modelName,compName,isComposition)

            [compAlreadyExists,m3iExistingComp]=...
            autosar.composition.Utils.isCompTypeInArchModel(modelName,compName);
            if compAlreadyExists
                m3iComponent=m3iExistingComp;
            else
                m3iModel=autosar.api.Utils.m3iModel(modelName);
                arProps=autosar.api.getAUTOSARProperties(modelName,true);
                compPkg=arProps.get('XmlOptions','ComponentPackage');
                m3iComponentPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,compPkg);
                isAdaptive=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);
                if isComposition
                    cMetaClassStr='Simulink.metamodel.arplatform.composition.CompositionComponent';
                elseif isAdaptive
                    cMetaClassStr='Simulink.metamodel.arplatform.component.AdaptiveApplication';
                else
                    cMetaClassStr='Simulink.metamodel.arplatform.component.AtomicComponent';
                end
                m3iComponent=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iComponentPkg,m3iComponentPkg.packagedElement,compName,cMetaClassStr);
            end
        end

    end

    methods(Static,Access=private)
        function isComponent=isComponentBlockAdded(blkH,copiedFromBlkH,compKindHint)
            isComponent=false;
            if autosar.composition.Utils.isComponentOrCompositionBlock(blkH)



                if~isempty(compKindHint)
                    if any(strcmp(compKindHint,autosar.composition.Utils.getSupportedComponentKinds()))
                        isComponent=true;
                        return;
                    elseif strcmp(compKindHint,'Composition')
                        isComponent=false;
                        return;
                    end
                end

                isCopiedFromAnotherComponentBlock=is_simulink_handle(copiedFromBlkH)&&...
                autosar.composition.Utils.isComponentBlock(copiedFromBlkH);

                if isCopiedFromAnotherComponentBlock
                    isComponent=true;
                    return;
                end

                isCopiedFromAnotherCompositionBlock=is_simulink_handle(copiedFromBlkH)&&...
                autosar.composition.Utils.isCompositionBlock(copiedFromBlkH);

                if isCopiedFromAnotherCompositionBlock
                    isComponent=false;
                    return;
                end

                isComponent=~startsWith(get_param(blkH,'Name'),'Composition');
            end
        end

        function isComposition=isCompositionBlockAdded(blkH,copiedFromBlkH,compKindHint)
            isComposition=autosar.composition.Utils.isComponentOrCompositionBlock(blkH)&&...
            ~autosar.composition.studio.SimulinkListener.isComponentBlockAdded(...
            blkH,copiedFromBlkH,compKindHint);
        end

        function compositeArPortAdded(blkH,copiedFromBlkH)%#ok<INUSD>
            import autosar.composition.studio.SimulinkListener;

            dstModelH=bdroot(blkH);
            m3iModel=autosar.api.Utils.m3iModel(dstModelH);


            portName=get_param(blkH,'PortName');


            m3iComp=autosar.composition.Utils.getM3ICompFromPortBlock(blkH);


            metaPkgName='Simulink.metamodel.arplatform';
            if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
                rPortSeqName='RequiredPorts';
                pPortSeqName='ProvidedPorts';
                rPortCls=[metaPkgName,'.port.ServiceRequiredPort'];
                pPortCls=[metaPkgName,'.port.ServiceProvidedPort'];
            else
                rPortSeqName='ReceiverPorts';
                pPortSeqName='SenderPorts';
                rPortCls=[metaPkgName,'.port.DataReceiverPort'];
                pPortCls=[metaPkgName,'.port.DataSenderPort'];
            end

            assert(m3iComp.isvalid(),'"%s" does not have a valid component name.',...
            getfullname(get_param(get_param(blkH,'Parent'),'Handle')));

            trans=M3I.Transaction(m3iModel);
            if autosar.composition.Utils.isDataReceiverPort(blkH)
                m3iPort=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iComp,m3iComp.(rPortSeqName),portName,rPortCls);%#ok<NASGU>
            elseif autosar.composition.Utils.isDataSenderPort(blkH)
                m3iPort=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iComp,m3iComp.(pPortSeqName),portName,pPortCls);%#ok<NASGU>
            else
                assert(false,'Unexpected port type for block: %s',getfullname(blkH));
            end
            trans.commit();
        end

        function arPortRemoved(blkH,portName)

            if isempty(portName)





                return
            end


            m3iModel=autosar.api.Utils.m3iModel(bdroot(blkH));
            m3iPort=autosar.composition.Utils.findM3IPortForCompositePort(blkH);
            if m3iPort.isvalid()
                trans=M3I.Transaction(m3iModel);
                m3iPort.destroy();
                trans.commit();
            end
        end

        function componentPrototypeAdded(blkH,copiedFromBlkH,isComposition,compKindHint)
            import autosar.composition.studio.SimulinkListener;


            modelName=getfullname(bdroot(blkH));
            m3iModelRoot=autosar.api.Utils.m3iModel(modelName);
            compPrototypeName=get_param(blkH,'Name');
            m3iCompositionParent=autosar.composition.Utils.findM3ICompositionParentForCompBlock(blkH);


            trans=M3I.Transaction(m3iModelRoot);
            m3iCompProto=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
            m3iCompositionParent,m3iCompositionParent.Components,compPrototypeName,...
            'Simulink.metamodel.arplatform.composition.ComponentPrototype');





            if~is_simulink_handle(copiedFromBlkH)||bdIsLibrary(bdroot(copiedFromBlkH))


                newCompName=compPrototypeName;
                m3iNewComp=autosar.composition.studio.SimulinkListener.getOrAddComponent(...
                modelName,newCompName,isComposition);
                if~isempty(compKindHint)
                    m3iNewComp.Kind=...
                    Simulink.metamodel.arplatform.component.AtomicComponentKind.fromString(compKindHint);
                end
                m3iCompProto.Type=m3iNewComp;
            elseif autosar.composition.Utils.isCompBlockNonLinked(copiedFromBlkH)


                newCompName=compPrototypeName;
                m3iNewComp=autosar.composition.studio.SimulinkListener.getOrAddComponent(...
                modelName,newCompName,isComposition);
                m3iCompProto.Type=m3iNewComp;


                m3iSrcCompProto=...
                autosar.composition.Utils.findM3ICompPrototypeForCompBlock(copiedFromBlkH);
                if m3iSrcCompProto.isvalid()
                    m3iSrcComp=m3iSrcCompProto.Type;
                    if m3iSrcComp.isvalid()
                        autosar.composition.studio.MetaModelSynchronizer.syncM3IComp(m3iSrcComp,m3iNewComp);
                    end
                end

            elseif autosar.composition.Utils.isCompBlockLinked(copiedFromBlkH)



                isCopyingWithinComposition=bdroot(copiedFromBlkH)==bdroot(blkH);
                if isCopyingWithinComposition



                    m3iSrcCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(copiedFromBlkH);
                    if m3iSrcCompProto.isvalid()
                        m3iSrcComp=m3iSrcCompProto.Type;
                        if m3iSrcComp.isvalid()
                            m3iCompProto.Type=m3iSrcComp;
                        end
                    end
                else


                    refModel=get_param(copiedFromBlkH,'ModelName');
                    if isvarname(refModel)
                        if~bdIsLoaded(refModel)
                            load_system(refModel);
                        end



                        if autosar.api.Utils.isMappedToComponent(refModel)
                            m3iSrcComp=autosar.api.Utils.m3iMappedComponent(refModel);
                            newCompName=m3iSrcComp.Name;


                            m3iNewComp=autosar.composition.studio.SimulinkListener.getOrAddComponent(...
                            modelName,newCompName,isComposition);
                            m3iCompProto.Type=m3iNewComp;



                            autosar.composition.studio.MetaModelSynchronizer.syncM3IComp(m3iSrcComp,m3iNewComp);
                        end
                    end
                end
            else



                if strcmp(get_param(blkH,'BlockType'),'SubSystem')
                    newCompName=compPrototypeName;
                    m3iNewComp=autosar.composition.studio.SimulinkListener.getOrAddComponent(...
                    modelName,newCompName,isComposition);
                    if~isempty(compKindHint)
                        m3iNewComp.Kind=...
                        Simulink.metamodel.arplatform.component.AtomicComponentKind.fromString(compKindHint);
                    end
                    m3iCompProto.Type=m3iNewComp;
                end
            end
            trans.commit();




            if strcmp(get_param(blkH,'BlockType'),'SubSystem')&&...
                autosar.composition.Utils.isComponentBlock(blkH)
                set_param(blkH,'OpenFcn','disp('''');');
            end
        end

        function componentPrototypeRemoved(blkH)
            import autosar.composition.studio.SimulinkListener


            m3iModel=autosar.api.Utils.m3iModel(bdroot(blkH));
            m3iComponentPrototype=...
            autosar.composition.Utils.findM3ICompPrototypeForCompBlock(blkH);

            if m3iComponentPrototype.isvalid()
                trans=M3I.Transaction(m3iModel);


                m3iCompTypesToDestroy={};
                m3iCompProtosToDestroy={};


                m3iCompProtosToDestroy{end+1}=m3iComponentPrototype;


                m3iCompType=m3iComponentPrototype.Type;
                if m3iCompType.isvalid()
                    m3iCompTypesToDestroy{end+1}=m3iCompType;


                    if autosar.composition.Utils.isM3IComposition(m3iCompType)
                        m3iCompProtosInsideComposition=...
                        autosar.composition.Utils.findCompPrototypesInComposition(m3iCompType);

                        for i=1:length(m3iCompProtosInsideComposition)
                            if m3iCompProtosInsideComposition(i).isvalid()
                                m3iCompProtosToDestroy{end+1}=m3iCompProtosInsideComposition(i);%#ok<AGROW>
                                if m3iCompProtosInsideComposition(i).Type.isvalid()
                                    m3iCompTypesToDestroy{end+1}=m3iCompProtosInsideComposition(i).Type;%#ok<AGROW>
                                end
                            end
                        end
                    end
                end


                cellfun(@(x)x.destroy(),m3iCompProtosToDestroy);




                for i=1:length(m3iCompTypesToDestroy)
                    m3iCompTypeToDestroy=m3iCompTypesToDestroy{i};
                    if m3iCompTypeToDestroy.isvalid()&&...
                        ~SimulinkListener.anyComponentPrototypesUsingCompType(m3iModel,m3iCompTypeToDestroy)
                        m3iCompTypeToDestroy.destroy();
                    end
                end
                trans.commit();
            end
        end

        function componentPrototypeCheckParamChange(blkH,paramName,newValue)
            switch(paramName)
            case 'Name'


                modelName=getfullname(bdroot(blkH));
                autosar.api.Utils.checkQualifiedName(modelName,newValue,'shortname');



                if~autosar.composition.Utils.isCompBlockLinked(blkH)
                    compositionModelName=getfullname(bdroot(blkH));
                    [isConflict,~,conflictingBlock]=...
                    autosar.composition.Utils.isCompTypeInArchModel(...
                    compositionModelName,newValue);
                    if isConflict
                        if isempty(conflictingBlock)


                            conflictingBlock=newValue;
                        end
                        DAStudio.error('autosarstandard:editor:RenameToCompWithConflictingName',...
                        getfullname(blkH),newValue,conflictingBlock);
                    end
                end
            otherwise
                assert(false,'should only be listening for check parameter "Name" change');
            end
        end

        function componentPrototypeParamChanged(blkH,paramName,oldValue,newValue)
            switch(paramName)
            case 'Name'

                m3iModel=autosar.api.Utils.m3iModel(bdroot(blkH));
                m3iCompositionParent=autosar.composition.Utils.findM3ICompositionParentForCompBlock(blkH);
                m3iComponentPrototype=...
                autosar.composition.Utils.findM3ICompPrototypeWithName(m3iCompositionParent,oldValue);

                if m3iComponentPrototype.isvalid()
                    trans=M3I.Transaction(m3iModel);


                    m3iComponentPrototype.Name=newValue;


                    if~autosar.composition.Utils.isCompBlockLinked(blkH)&&...
                        m3iComponentPrototype.Type.isvalid()
                        m3iComponentPrototype.Type.Name=newValue;
                    end

                    trans.commit();
                end
            case 'ModelName'
                assert(autosar.composition.Utils.isCompBlockLinked(blkH),...
                '%s should be linked to a model',getfullname(blkH));


                m3iCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(blkH);

                if m3iCompProto.isvalid()
                    reModelName=newValue;
                    if~bdIsLoaded(reModelName)
                        load_system(reModelName);
                    end

                    m3iRefComp=autosar.api.Utils.m3iMappedComponent(reModelName);
                    autosar.composition.studio.AUTOSARComponentToModelLinker.syncCompBlockWithImportedM3IComp(...
                    blkH,m3iRefComp,'SyncCompName',true);
                end
            otherwise
                assert(false,'should only be listening for parameter "Name" change');
            end
        end

        function compLinkedModelCheckParamChange(blkH,paramName,newValue)
            switch(paramName)
            case 'ModelName'

                selectedModelValid=autosar.composition.studio.CompBlockReferenceModel.validateModel(...
                newValue,blkH);
                if~selectedModelValid

                    componentBlockModelReferencer=autosar.composition.studio.CompBlockReferenceModel(blkH);
                    componentBlockModelReferencer.referenceModel(newValue);
                end
            otherwise
                assert(false,'should only be listening for parameter "ModelName" change');
            end
        end

        function compositePortBlockParamChanged(blkH,paramName,oldValue,newValue)
            switch(paramName)
            case 'PortName'

                m3iComp=autosar.composition.Utils.getM3ICompFromPortBlock(blkH);
                m3iPort=autosar.composition.Utils.findM3IPortWithName(m3iComp,oldValue);
                if m3iPort.isvalid()
                    trans=M3I.Transaction(m3iPort.rootModel);
                    m3iPort.Name=newValue;
                    trans.commit();
                end
            otherwise

            end
        end

        function componentBlockAdded(blkH,copiedFromBlkH,compKindHint)
            autosar.composition.studio.SimulinkListener.componentPrototypeAdded(...
            blkH,copiedFromBlkH,false,compKindHint);
        end

        function compositionBlockAdded(blkH,copiedFromBlkH)
            autosar.composition.studio.SimulinkListener.componentPrototypeAdded(...
            blkH,copiedFromBlkH,true,'');
        end

        function compositePortBlockAdded(blkH,copiedFromBlkH)
            autosar.composition.studio.SimulinkListener.compositeArPortAdded(blkH,copiedFromBlkH);
        end

        function componentBlockRemoved(blkH)
            autosar.composition.studio.SimulinkListener.componentPrototypeRemoved(blkH);
        end

        function compositionBlockRemoved(blkH)
            autosar.composition.studio.SimulinkListener.componentPrototypeRemoved(blkH);
        end

        function compBlockCheckParamChange(blkH,paramName,newValue)
            switch paramName
            case 'Name'

                autosar.composition.studio.SimulinkListener.componentPrototypeCheckParamChange(...
                blkH,paramName,newValue);
            case 'ModelName'

                autosar.composition.studio.SimulinkListener.compLinkedModelCheckParamChange(...
                blkH,paramName,newValue);
            otherwise
                assert(false,'Should only listen for "Name" and "ModelName"');
            end
        end

        function componentBlockParamChanged(blkH,paramName,oldValue,newValue)
            autosar.composition.studio.SimulinkListener.componentPrototypeParamChanged(...
            blkH,paramName,oldValue,newValue);
        end

        function compositionBlockParamChanged(blkH,paramName,oldValue,newValue)
            autosar.composition.studio.SimulinkListener.componentPrototypeParamChanged(...
            blkH,paramName,oldValue,newValue);
        end
    end
end



