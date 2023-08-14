classdef(Hidden)Utils





    methods(Static)

        function modelMapping=modelMapping(modelName)
            modelMapping=autosarcore.ModelUtils.modelMapping(modelName);
        end

        function m3iModel=m3iModel(modelOrInterfaceDictName,varargin)
            m3iModel=autosarcore.M3IModelLoader.loadM3IModel(modelOrInterfaceDictName,varargin{:});
        end

        function[isSharedDict,dictFiles]=isUsingSharedAutosarDictionary(modelName)
            [isSharedDict,dictFiles]=autosarcore.ModelUtils.isUsingSharedAutosarDictionary(modelName);
        end


        function m3iComp=m3iMappedComponent(modelName)
            m3iComp=autosarcore.ModelUtils.m3iMappedComponent(modelName);
        end

        function compQName=convertComponentIdToQName(componentId)
            compQName=autosarcore.ModelUtils.convertComponentIdToQName(componentId);
        end

        function setM3iModelDirty(modelName)




            Simulink.slx.setPartDirty(modelName,'autosar');




            m3iModel=autosar.api.Utils.m3iModel(modelName);
            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)
                Simulink.AutosarDictionary.ModelRegistry.setParentModelDirtyFlag(m3iModel,true);
            end
        end

        function msgStream=initMessageStreamHandler()

            msgStream=autosar.mm.util.MessageStreamHandler.initMessageStreamHandler();
        end

        function[isMapped,modelMapping]=isMapped(modelName)


            [isMapped,modelMapping]=autosarcore.ModelUtils.isMapped(modelName);
        end


        function[isMapped,modelMapping]=isMappedToComponent(modelName)
            [isMapped,modelMapping]=autosarcore.ModelUtils.isMappedToComponent(modelName);
        end

        function[isMapped,modelMapping]=isMappedToAdaptiveApplication(modelName)
            [isMapped,modelMapping]=autosarcore.ModelUtils.isMappedToAdaptiveApplication(modelName);
        end

        function[isMapped,modelMapping]=isMappedToComposition(modelName)
            [isMapped,modelMapping]=autosarcore.ModelUtils.isMappedToComposition(modelName);
        end



        function isConsistent=isMappedModelConsistentWithSTF(modelName)
            assert(autosar.api.Utils.isMapped(modelName),'model %s is not mapped.',modelName);
            isAdaptiveConsistent=(Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)&&...
            autosar.api.Utils.isMappedToAdaptiveApplication(modelName));
            isClassicConsistent=(~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)&&...
            ~autosar.api.Utils.isMappedToAdaptiveApplication(modelName));
            isConsistent=isAdaptiveConsistent||isClassicConsistent;
        end

        function mappedName=componentName(modelName)

            modelMapping=autosar.api.Utils.modelMapping(modelName);
            mappedName=modelMapping.MappedTo.Name;
        end

        function mappingName=createMappingName(modelName,mappingType)


            mappingName=autosarcore.ModelUtils.createMappingName(modelName,mappingType);
        end

        function modelName=getModelNameFromMapping(mapping)




            assert(any(strcmp(class(mapping),...
            {'Simulink.AutosarTarget.ModelMapping',...
            'Simulink.AutosarTarget.AdaptiveModelMapping',...
            'Simulink.AutosarTarget.CompositionModelMapping'})),...
            'Unexpected mapping type');




            underscoreIdx=strfind(mapping.Name,'_');
            modelName=mapping.Name(1:underscoreIdx(end)-1);
        end

        function mappingType=getMappingType(modelName)

            mappingType=autosarcore.ModelUtils.getMappingType(modelName);
        end

        function[islicensed,errorargs]=autosarlicensed(throwError)












            islicensed=true;

            if nargin<1
                throwError=false;
            end

            licenses={'AUTOSAR_Blockset'};
            missing={};
            additionalInfo={};
            for cellitem=licenses
                lic=cellitem{1};
                [tf,errmsg]=license('checkout',lic);
                if tf==0
                    missing{end+1}=lic;%#ok<AGROW>
                    islicensed=false;
                    if~isempty(errmsg)
                        additionalInfo{end+1}=sprintf('%s: %s',lic,errmsg);%#ok<AGROW>
                    end
                end
            end

            errorargs={'RTW:autosar:LicenseNotAvailable',...
            strjoin(missing,', '),...
            strjoin(additionalInfo,'\n\n')};

            if~islicensed&&throwError
                try
                    DAStudio.error(errorargs{:});
                catch ME

                    throwAsCaller(ME);
                end
            end
        end

        function[app2ImpMap,modeRteCallMap,mode2ImpMap]=app2ImpMap(modelName,varargin)



            app2ImpMap=containers.Map();
            mode2ImpMap=containers.Map();
            modeRteCallMap=containers.Map();
            useFullPath=false;

            if nargin>1
                useFullPath=varargin{1};
            end


            dataobj=autosar.api.getAUTOSARProperties(modelName,true);
            componentQualifiedName=dataobj.get('XmlOptions','ComponentQualifiedName');
            mappedIbQNames=dataobj.find(componentQualifiedName,'ApplicationComponentBehavior','PathType','FullyQualified');

            if isempty(mappedIbQNames)
                return
            end

            assert(length(mappedIbQNames)==1,'Expected to find only one internal behavior');

            ibPath=mappedIbQNames{1};
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iObjSeq=autosar.mm.Model.findObjectByName(m3iModel,ibPath);
            m3iBehavior=m3iObjSeq.at(1);

            for setIdx=1:m3iBehavior.DataTypeMapping.size()
                m3iDataTypeMapping=m3iBehavior.DataTypeMapping.at(setIdx);
                for mapIdx=1:m3iDataTypeMapping.dataTypeMap.size()
                    m3iDataTypeMap=m3iDataTypeMapping.dataTypeMap.at(mapIdx);

                    if~m3iDataTypeMap.ApplicationType.isvalid()||...
                        ~m3iDataTypeMap.ImplementationType.isvalid()
                        continue;
                    end

                    if useFullPath
                        app2ImpMap(autosar.api.Utils.getQualifiedName(m3iDataTypeMap.ApplicationType))=autosar.api.Utils.getQualifiedName(m3iDataTypeMap.ImplementationType);
                    else
                        appTypeName=autosar.api.Utils.getUnmangledName(m3iDataTypeMap.ApplicationType);
                        app2ImpMap(appTypeName)=m3iDataTypeMap.ImplementationType.Name;
                    end
                end
                for mapIdx=1:m3iDataTypeMapping.ModeRequestTypeMap.size()
                    m3iModeTypeMap=m3iDataTypeMapping.ModeRequestTypeMap.at(mapIdx);

                    if~m3iModeTypeMap.ModeGroupType.isvalid()||...
                        ~m3iModeTypeMap.ImplementationType.isvalid()
                        continue;
                    end

                    if useFullPath
                        mode2ImpMap(autosar.api.Utils.getQualifiedName(m3iModeTypeMap.ModeGroupType))=autosar.api.Utils.getQualifiedName(m3iDataTypeMap.ImplementationType);
                    else
                        mdgName=autosar.api.Utils.getUnmangledName(m3iModeTypeMap.ModeGroupType);
                        mode2ImpMap(mdgName)=m3iModeTypeMap.ImplementationType.Name;
                    end
                end
            end

            for setIdx=1:m3iBehavior.Runnables.size()
                m3iRunnables=m3iBehavior.Runnables.at(setIdx);
                for mapIdx=1:m3iRunnables.ModeSwitchPoint.size()
                    m3iModeSwitchTypeMap=m3iRunnables.ModeSwitchPoint.at(mapIdx);
                    m3iModeSwitchInstRef=m3iModeSwitchTypeMap.InstanceRef;
                    if(m3iModeSwitchInstRef.isvalid())
                        m3iMdg=m3iModeSwitchInstRef.groupElement.ModeGroup;
                        if m3iMdg.isvalid()
                            m3iModes=m3iMdg.Mode;
                            for modeIdx=1:m3iModes.size()
                                m3iMode=m3iModes.at(modeIdx);
                                modeRteCallMap(m3iMode.Name)=['RTE_MODE_',m3iMdg.Name,'_',m3iMode.Name];
                            end
                        end
                    end
                end

                for mapIdx=1:m3iRunnables.ModeAccessPoint.size()
                    m3iModeAccessTypeMap=m3iRunnables.ModeAccessPoint.at(mapIdx);
                    m3iModeAccessInstRef=m3iModeAccessTypeMap.InstanceRef;
                    if(m3iModeAccessInstRef.isvalid())
                        m3iMdg=m3iModeAccessInstRef.groupElement.ModeGroup;
                        if m3iMdg.isvalid()
                            m3iModes=m3iMdg.Mode;
                            for modeIdx=1:m3iModes.size()
                                m3iMode=m3iModes.at(modeIdx);
                                modeRteCallMap(m3iMode.Name)=['RTE_MODE_',m3iMdg.Name,'_',m3iMode.Name];
                            end
                        end
                    end
                end
            end

        end

        function checkQualifiedName(modelName,qualifiedName,idType)
            autosarcore.ModelUtils.checkQualifiedName(modelName,qualifiedName,idType);
        end

        function setUnmangledName(m3iAppType,unmangledName)
            toolId='ARXML_UNMANGLED_SHORT_NAME';
            autosar.mm.Model.setExtraExternalToolInfo(m3iAppType,...
            toolId,{'%s'},{unmangledName});
        end

        function name=getUnmangledName(m3iAppType)
            toolId='ARXML_UNMANGLED_SHORT_NAME';
            extraInfo=autosar.mm.Model.getExtraExternalToolInfo(...
            m3iAppType,toolId,{'shortName'},{'%s'});
            if~isempty(extraInfo.shortName)
                name=extraInfo.shortName;
            else
                name=m3iAppType.Name;
            end
        end

        function syncComponentQualifiedName(m3iModel,oldComponentQualifiedName,...
            componentQualifiedName)






            if~isempty(oldComponentQualifiedName)&&~isempty(componentQualifiedName)...
                &&~strcmp(oldComponentQualifiedName,componentQualifiedName)


                compObjs=autosar.mm.Model.findObjectByName(m3iModel,...
                oldComponentQualifiedName);
                assert(~isempty(compObjs)&&(compObjs.size==1),...
                'Expect to find a unique component by this name');
                compObj=compObjs.at(1);
                [compPath,compName,~]=fileparts(componentQualifiedName);


                newCompObjs=autosar.mm.Model.findObjectByName(m3iModel,...
                componentQualifiedName);
                if~isempty(newCompObjs)&&(newCompObjs.size==1)
                    DAStudio.error('RTW:autosar:ComponentExistsError',...
                    compName,compPath);
                end


                m3iSWCPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,...
                compPath);


                compObj.Name=compName;
                m3iSWCPkg.packagedElement.push_back(compObj);
            end
        end

        function ret=getCanBeInvokedConcurrently(~,~)





            if slfeature('TestingCanBeInvokedConcurrently')>0
                ret=true;
            else
                ret=false;
            end
        end



        function mapCaller(modelName,mappingObj,clientPortName,operationName,...
            varargin)

            if isempty(clientPortName)
                mappingObj.mapPortOperation('','');
            else

                if isempty(operationName)&&length(varargin)>=1&&...
                    isa(varargin{1},'Simulink.metamodel.arplatform.port.ClientPort')



                    disableChecks=true;
                elseif~isempty(operationName)&&length(varargin)>=1&&...
                    isa(varargin{1},'Simulink.metamodel.arplatform.interface.Operation')



                    disableChecks=true;
                else


                    disableChecks=false;
                end
                if~disableChecks
                    m3iModel=autosar.api.Utils.m3iModel(modelName);

                    dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                    componentQualifiedName=dataObj.get('XmlOptions',...
                    'ComponentQualifiedName');

                    portMetaClass=Simulink.metamodel.arplatform.port.ClientPort.MetaClass();
                    m3iClientPort=autosar.mm.Model.findObjectByNameAndMetaClass(...
                    m3iModel,[componentQualifiedName,'/',clientPortName],...
                    portMetaClass);
                    if m3iClientPort.size()~=1
                        DAStudio.error('RTW:autosar:uniqueClientPortNotFound',...
                        m3iClientPort.size());
                    end
                end
                mappingObj.mapPortOperation(clientPortName,'');

                if~isempty(operationName)
                    if~disableChecks
                        m3iOperation=autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(...
                        modelName,clientPortName,operationName);
                        if isempty(m3iOperation)
                            DAStudio.error('RTW:autosar:uniqueOpNotFoundForClientPort',...
                            operationName,clientPortName);
                        end
                        [isMappable,~,~]=...
                        autosar.validation.ClientServerValidator.checkFcnCallerMappableToOperation(...
                        mappingObj.Block,m3iOperation);
                        if~isMappable
                            DAStudio.error('RTW:autosar:unableToMapFcnCaller',...
                            mappingObj.Block,clientPortName,operationName);
                        end
                    end


                    mappingObj.mapPortOperation(clientPortName,operationName);
                end
            end
        end



        function mapFunction(modelName,mappingObj,ARRunnableName)


            if isempty(ARRunnableName)
                mappingObj.MappedTo.RunnableSymbol='';
            else

                m3iRunnableObj=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                modelName,ARRunnableName);
                if isempty(m3iRunnableObj)
                    DAStudio.error(...
                    'RTW:autosar:invalidRunnableName',ARRunnableName);
                end



                if isa(mappingObj,'Simulink.AutosarTarget.BlockMapping')&&...
                    autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(mappingObj.Block)
                    [isMappable,~,msg]=autosar.validation.ClientServerValidator.checkSlFcnMappableToRunnable(...
                    mappingObj.Block,m3iRunnableObj);
                    if~isMappable
                        autosar.api.Utils.mapFunction(modelName,mappingObj,'');
                        if~isempty(msg)
                            throw(msg);
                        end
                        return;
                    end
                end


                mappingObj.mapEntryPoint(ARRunnableName,'');
            end


            mappingObj.mapEntryPoint(ARRunnableName,'');
        end




        function addPrototypeControlInfo(modelName)
            if~autosar.api.Utils.isMapped(modelName)
                return;
            end


            mapping=autosar.api.Utils.modelMapping(modelName);
            mapping.sync();




            mapping.syncFunctionCallers();



            addPrototypControlHelper(modelName,mapping.InitializeFunctions);
            addPrototypControlHelper(modelName,mapping.ResetFunctions);
            addPrototypControlHelper(modelName,mapping.TerminateFunctions);
            addPrototypControlHelper(modelName,mapping.FcnCallInports);
            addPrototypControlHelper(modelName,mapping.StepFunctions);
            addPrototypControlHelper(modelName,mapping.ServerFunctions);



            for i=1:length(mapping.ServerFunctions)
                if isempty(mapping.ServerFunctions(i).MappedTo)
                    continue;
                end
                runnableName=mapping.ServerFunctions(i).MappedTo.Runnable;
                if isempty(runnableName)
                    continue;
                end
                m3iRunnableObj=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                modelName,runnableName);
                if isempty(m3iRunnableObj)
                    continue;
                end
                for ii=1:m3iRunnableObj.Events.size
                    m3iEvent=m3iRunnableObj.Events.at(ii);
                    if isa(m3iEvent,...
                        'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent')
                        if isempty(m3iEvent.instanceRef)
                            continue;
                        end
                        m3iOp=m3iEvent.instanceRef.Operations;
                        cImpl=getBlockCImpl(m3iOp,mapping.ServerFunctions(i).Block);
                        cImpl.Name=m3iRunnableObj.symbol;
                        mapping.ServerFunctions(i).MappedTo.RunnablePrototype=cImpl;
                        continue;
                    elseif isa(m3iEvent,...
                        'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent')



                        cImpl=RTW.CImplementation;
                        cImpl.Name=m3iRunnableObj.symbol;
                        mapping.ServerFunctions(i).MappedTo.RunnablePrototype=cImpl;
                        continue;
                    end
                end
            end

            for i=1:length(mapping.FunctionCallers)
                if isempty(mapping.FunctionCallers(i).MappedTo)
                    continue;
                end
                clientPortName=mapping.FunctionCallers(i).MappedTo.ClientPort;
                operationName=mapping.FunctionCallers(i).MappedTo.Operation;
                if isempty(clientPortName)||isempty(operationName)
                    continue;
                end
                if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(...
                    mapping.FunctionCallers(i).Block)

                    continue
                end
                m3iOperation=autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(...
                modelName,clientPortName,operationName);
                if isempty(m3iOperation)
                    continue;
                end
                cImpl=getBlockCImpl(m3iOperation,mapping.FunctionCallers(i).Block);
                cImpl.Name=operationName;
                mapping.FunctionCallers(i).MappedTo.RunnablePrototype=cImpl;
            end
        end

        function clearPrototypeControlInfo(modelName)
            if~autosar.api.Utils.isMapped(modelName)
                return;
            end


            mapping=autosar.api.Utils.modelMapping(modelName);


            if~autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                for i=1:length(mapping.InitializeFunctions)
                    if~isempty(mapping.InitializeFunctions(i).MappedTo)
                        mapping.InitializeFunctions(i).MappedTo.RunnablePrototype.Name='';
                    end
                end
                for i=1:length(mapping.TerminateFunctions)
                    if~isempty(mapping.TerminateFunctions(i).MappedTo)
                        mapping.TerminateFunctions(i).MappedTo.RunnablePrototype.Name='';
                    end
                end
                for i=1:length(mapping.ResetFunctions)
                    if~isempty(mapping.ResetFunctions(i).MappedTo)
                        mapping.ResetFunctions(i).MappedTo.RunnablePrototype.Name='';
                    end
                end
                for i=1:length(mapping.FcnCallInports)
                    if~isempty(mapping.FcnCallInports(i).MappedTo)
                        mapping.FcnCallInports(i).MappedTo.RunnablePrototype.Name='';
                    end
                end
                for i=1:length(mapping.StepFunctions)
                    if~isempty(mapping.StepFunctions(i).MappedTo)
                        mapping.StepFunctions(i).MappedTo.RunnablePrototype.Name='';
                    end
                end
                for i=1:length(mapping.ServerFunctions)
                    if~isempty(mapping.ServerFunctions(i).MappedTo)
                        serverProto=mapping.ServerFunctions(i).MappedTo.RunnablePrototype;
                        serverProto.Arguments=[];
                        serverProto.Name='';
                        serverProto.Return=[];
                    end
                end
                for i=1:length(mapping.FunctionCallers)
                    if~isempty(mapping.FunctionCallers(i).MappedTo)
                        callerProto=mapping.FunctionCallers(i).MappedTo.RunnablePrototype;
                        callerProto.Arguments=[];
                        callerProto.Name='';
                        callerProto.Return=[];
                    end
                end
            end
        end

        function hasClash=checkRunnableSymbolClash(m3iObject,propValue)
            m3iParentObj=m3iObject.containerM3I;
            siblingSeq=m3iParentObj.containeeM3I;
            for ii=1:siblingSeq.size
                m3iSiblingObj=siblingSeq.at(ii);
                if(m3iSiblingObj==m3iObject)
                    continue;
                elseif isa(m3iSiblingObj,...
                    'Simulink.metamodel.arplatform.behavior.Runnable')&&...
                    strcmp(propValue,m3iSiblingObj.symbol)
                    hasClash=true;
                    return;
                end
            end
            hasClash=false;
        end




        function m3iCompositions=findCompositionsUsingComponent(m3iObj)
            m3iCompositions=[];
            if isa(m3iObj,'Simulink.metamodel.arplatform.component.Component')
                m3iCompositionSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
                m3iObj.rootModel,Simulink.metamodel.arplatform.composition.CompositionComponent.MetaClass,true);
                for idx=1:m3iCompositionSeq.size()
                    m3iComposition=m3iCompositionSeq.at(idx);
                    m3iSWCs=m3i.mapcell(@(x)x.Type,m3iComposition.Components);
                    if any(cellfun(@(x)x==m3iObj,m3iSWCs))&&...
                        ~any(arrayfun(@(x)x==m3iComposition,m3iCompositions))
                        m3iCompositions=[m3iCompositions,m3iComposition];%#ok<AGROW>
                    end
                end
            end
        end

        function objs=findElementsByClassName(arRoot,srcPkg,metaClsStr)
            import autosar.mm.Model;
            import autosar.api.Utils;

            objs=[];
            m3iSrcPkg=Model.getArPackage(arRoot,srcPkg);
            if isempty(m3iSrcPkg)
                return;
            end
            objs=Model.findChildByTypeName(m3iSrcPkg,metaClsStr,false,true);
        end
        function moveElementsByClassName(arRoot,srcPkg,destPkg,...
            metaClsStr,moveElementsMode)
            import autosar.mm.Model;
            import autosar.api.Utils;

            if strcmp(moveElementsMode,'None')||~isValidMove(arRoot,srcPkg,destPkg)
                return;
            end
            objs=Utils.findElementsByClassName(arRoot,srcPkg,metaClsStr);
            if numel(objs)>0
                childMetaClass=autosar.api.getAUTOSARProperties.getMetaClassFromCategory(metaClsStr);
                if~shouldMoveElements(srcPkg,destPkg,[childMetaClass.name,'s'],moveElementsMode)
                    return;
                end
                pkgM3iDest=Model.getOrAddARPackage(arRoot,destPkg);
                for ii=1:numel(objs)
                    if~autosar.mm.arxml.Exporter.isExternalReference(objs{ii})
                        pkgM3iDest.packagedElement.append(objs{ii});
                    end
                end
            end
        end

        function moveDataConstrs(arRoot,srcPkg,destPkg,isAppType,moveElementsMode)
            import autosar.mm.Model;
            import autosar.api.Utils;

            if strcmp(moveElementsMode,'None')||~isValidMove(arRoot,srcPkg,destPkg)
                return;
            end
            metaClsStr='Simulink.metamodel.types.DataConstr';
            objs=Utils.findElementsByClassName(arRoot,srcPkg,metaClsStr);
            if numel(objs)>0
                if isAppType
                    category='Physical DataConstraints';
                else
                    category='Internal DataConstraints';
                end
                if~shouldMoveElements(srcPkg,destPkg,category,moveElementsMode)
                    return;
                end
                pkgM3iDest=Model.getOrAddARPackage(arRoot,destPkg);
                for ii=1:numel(objs)
                    if~autosar.mm.arxml.Exporter.isExternalReference(objs{ii})
                        if objs{ii}.PrimitiveType.size()>0
                            if isAppType==objs{ii}.PrimitiveType.at(1).IsApplication
                                pkgM3iDest.packagedElement.append(objs{ii});
                            end
                        else
                            pkgM3iDest.packagedElement.append(objs{ii});
                        end
                    end
                end
            end
        end

        function shouldMove=moveDataTypesByClass(arRoot,srcPkg,destPkg,metaClsStr,isAppType,moveElementsMode)
            import autosar.mm.Model;
            import autosar.api.Utils;
            shouldMove=false;
            if strcmp(moveElementsMode,'None')||~isValidMove(arRoot,srcPkg,destPkg)
                return;
            end
            objs=Utils.findElementsByClassName(arRoot,srcPkg,metaClsStr);
            if numel(objs)>0
                if isAppType
                    category='ApplicationDataTypes';
                else
                    category='ImplementationDataTypes';
                end
                shouldMove=shouldMoveElements(srcPkg,destPkg,category,moveElementsMode);
                if~shouldMove
                    return;
                end
                pkgM3iDest=Model.getOrAddARPackage(arRoot,destPkg);
                for ii=1:numel(objs)
                    if~autosar.mm.arxml.Exporter.isExternalReference(objs{ii})
                        if isAppType==objs{ii}.IsApplication
                            pkgM3iDest.packagedElement.append(objs{ii});
                        end
                    end
                end
            end
        end

        function moveAppDataTypes(arRoot,srcPkg,destPkg,moveElementsMode)
            import autosar.api.Utils;


            if strcmp(destPkg,arRoot.DataTypePackage)
                return;
            end
            Utils.moveDataTypesByClass(arRoot,srcPkg,destPkg,...
            'Simulink.metamodel.foundation.ValueType',true,moveElementsMode);
        end

        function moveImpDataTypes(arRoot,srcPkg,destPkg,moveElementsMode)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.api.Utils;


            if strcmp(moveElementsMode,'None')||strcmp(destPkg,XmlOptionsAdapter.get(arRoot,'ApplicationDataTypePackage'))
                return;
            end
            tp='Simulink.metamodel.types';
            shouldMove=Utils.moveDataTypesByClass(arRoot,srcPkg,destPkg,...
            'Simulink.metamodel.foundation.ValueType',false,moveElementsMode);
            if shouldMove
                Utils.moveElementsByClassName(arRoot,...
                [srcPkg,'/DataConstrs'],[destPkg,'/DataConstrs'],[tp,'.DataConstr'],'All');
            end
        end

        function path=getQualifiedName(m3iObj)
            if~m3iObj.isvalid

                path=[];
            else


                hasValidQualifiedName=m3iObj.has('Name')&&startsWith(m3iObj.qualifiedName,'AUTOSAR.');
                if hasValidQualifiedName
                    path=regexprep(m3iObj.qualifiedNameWithSeparator('/'),'^AUTOSAR','');
                else
                    path=autosar.api.UnnamedElement.getQualifiedName(m3iObj);
                end
            end
        end

        function isNamed=isNamedElement(elementName)
            isNamed=~autosar.api.UnnamedElement.isUnnamed(elementName);
        end

        function uuid=getUUID(m3iObj)
            uuid=m3iObj.getExternalToolInfo('ARXML').externalId;
        end

        function eventTriggers=getDataReceivedEventTriggers(m3iComp,slMapping)



            validPortElements=autosar.mm.util.InstanceRefAdapter.getValidShortIds(m3iComp,'FlowDataPortInstanceRef');

            mappedPortElements=cell(0,1);
            for ii=1:length(slMapping.Inports)
                inport=slMapping.Inports(ii);
                if~strcmp(inport.MappedTo.DataAccessMode,...
                    autosar.ui.metamodel.PackageString.ModeAccessType)&&...
                    ~isempty(inport.MappedTo.Port)&&...
                    ~isempty(inport.MappedTo.Element)
                    mappedPortElements{end+1}=[inport.MappedTo.Port,'.'...
                    ,inport.MappedTo.Element];%#ok<AGROW>
                end
            end
            mappedPortElements=unique(mappedPortElements,'stable');




            eventTriggers=intersect(mappedPortElements,validPortElements);
        end

        function eventTriggers=getExternalTriggerOccurredEventTriggers(m3iComp)




            eventTriggers=autosar.mm.util.InstanceRefAdapter.getValidShortIds(m3iComp,'TriggerInstanceRef');
        end

        function str=cell2str(cellArray)

            str='';
            sep='';
            for ii=1:length(cellArray)
                str=sprintf('%s%s''%s''',str,sep,cellArray{ii});
                sep=', ';
            end
            str=sprintf('%s',str);
        end

        function errIDAndHoles=verifyXmlOptionsPackage(m3iModel,...
            propertyValueCurrent,propertyValue,propertyName)















            errIDAndHoles={[],[],[]};

            if isempty(propertyValue)
                if~isempty(propertyValueCurrent)
                    packages=autosar.api.getAUTOSARProperties.getAllPackagePaths(m3iModel);
                    if ismember(propertyValueCurrent,packages)
                        errIDAndHoles={'autosarstandard:ui:emptyPackagePath',propertyName};
                    end
                end
            else
                maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(m3iModel);
                [idcheckmessage,errId]=autosar.ui.utils.isValidARIdentifier(...
                {propertyValue},'absPath',maxShortNameLength);
                if~isempty(idcheckmessage)

                    invalidLengthErrIds={...
                    'RTW:autosar:invalidShortNameLength',...
                    'RTW:autosar:invalidAbsPathShortNameLength',...
                    'RTW:autosar:invalidAbsPathLength'};
                    if ismember(errId,invalidLengthErrIds)
                        errIDAndHoles={errId,propertyValue,maxShortNameLength};
                    else
                        errIDAndHoles={errId,propertyValue};
                    end
                end
            end
        end

        function[isMapped,nvmServiceName]=isMappedToNvmService(slFcnPath)


            isMapped=false;
            nvmServiceName='';

            mdlName=bdroot(slFcnPath);
            modelMapping=autosar.api.Utils.modelMapping(mdlName);

            slFcnPath=strrep(slFcnPath,newline,' ');
            slFunction=modelMapping.ServerFunctions.findobj('Block',slFcnPath);
            if~isempty(slFunction)
                m3iRunnable=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                mdlName,slFunction.MappedTo.Runnable);
                allM3IOp=autosar.validation.ClientServerValidator.getAllRunnableOperations(m3iRunnable);
                if~isempty(allM3IOp)
                    m3iOperation=allM3IOp{1};
                    if autosar.validation.ClientServerValidator.isNvMService(m3iOperation)
                        isMapped=true;
                        nvmServiceName=m3iOperation.Name;
                    end
                end
                return
            end
            fcnCaller=modelMapping.FunctionCallers.findobj('Block',slFcnPath);
            if~isempty(fcnCaller)
                if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(fcnCaller.Block)

                    return
                end
                m3iOperation=...
                autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(mdlName,...
                fcnCaller.MappedTo.ClientPort,...
                fcnCaller.MappedTo.Operation);
                if autosar.validation.ClientServerValidator.isNvMService(m3iOperation)
                    isMapped=true;
                    nvmServiceName=m3iOperation.Name;
                end
                return
            end

            assert(false,'Did not find either Simulink Function or function-caller %s in mapping',slFcnPath);

        end

        function isNvPort=isNvPort(m3iPort)

            isNvPort=isa(m3iPort,'Simulink.metamodel.arplatform.port.NvDataReceiverPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.NvDataSenderPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort');


        end

        function isMsPort=isMsPort(m3iPort)
            isMsPort=isa(m3iPort,'Simulink.metamodel.arplatform.port.ModeReceiverPort')||...
            isa(m3iPort,'Simulink.metamodel.arplatform.port.ModeSenderPort');
        end

        function result=isTriggerPort(m3iPort)
            result=isa(m3iPort,'Simulink.metamodel.arplatform.port.TriggerReceiverPort');
        end

        function isUpdatedPortElement=isUpdatedPortElement(m3iPort,m3iDataElement,slPortType)
            switch slPortType
            case 'Inport'
                m3iComSpec=autosar.mm.Model.findComSpecForDataElement(m3iPort,m3iDataElement.Name,true);
                isUpdatedPortElement=isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec')&&...
                m3iComSpec.EnableUpdate;
            case 'Outport'
                isUpdatedPortElement=false;
            otherwise
                assert(false,'Unknown slPortType of %s',slPortType)
            end
        end




        function isErrorStatus=isErrorStatusPortElement(m3iPort,m3iDataElement,accessKindStr)
            isErrorStatus=false;




            isSupportedReadAccess=any(strcmp(accessKindStr,{'ImplicitRead','ExplicitReadByArg','read'}));
            if isSupportedReadAccess
                m3iComSpec=autosar.mm.Model.findComSpecForDataElement(m3iPort,m3iDataElement.Name,true);
                if isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec')






                    dataElementInvalidationPolicy=m3iDataElement.InvalidationPolicy.toString();
                    isErrorStatus=any(strcmp(dataElementInvalidationPolicy,{'Keep','Replace'}))||...
                    ~isempty(m3iComSpec.HandleNeverReceived)&&m3iComSpec.HandleNeverReceived||...
                    ~isempty(m3iComSpec.UsesEndToEndProtection)&&m3iComSpec.UsesEndToEndProtection||...
                    ~isempty(m3iComSpec.AliveTimeout)&&(m3iComSpec.AliveTimeout>0);
                end
            end
        end


        function datatypeStr=getSLTypeForErrorStatusPort(m3iPort,m3iDataElement)
            datatypeStr='uint8';
            m3iComSpec=autosar.mm.Model.findComSpecForDataElement(m3iPort,m3iDataElement.Name,true);
            if~autosar.mm.mm2sl.utils.doesPortUseE2EErrorHandlingTransformer(m3iPort)&&...
                isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec')
                if m3iComSpec.UsesEndToEndProtection
                    datatypeStr='uint32';
                end
            end
        end

        function isArraySizeOne=isArraySizeOne(m3iType)

            if slsvTestingHook('TestScalarPassByPointerForAutosar')>=100
                isArraySizeOne=true;
                return
            end

            isArraySizeOne=false;

            if~m3iType.isvalid()
                return
            end

            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                arraySize=1;
                for ii=1:m3iType.Dimensions.size()
                    arraySize=arraySize*m3iType.Dimensions.at(ii);
                end

                if arraySize==1&&m3iType.Dimensions.size()>0
                    isArraySizeOne=true;
                end
            end

        end

        function m3iSystemConstantValueSets=getSystemConstValueSetsFromPredefinedVariant(m3iObj,m3iSystemConstantValueSets)
            for ii=1:m3iObj.SysConstValueSet.size()
                m3iSystemConstantValueSets=[m3iSystemConstantValueSets,m3iObj.SysConstValueSet.at(ii)];%#ok<AGROW>
            end
            for ii=1:m3iObj.IncludedVariant.size()
                m3iSystemConstantValueSets=...
                autosar.api.Utils.getSystemConstValueSetsFromPredefinedVariant(...
                m3iObj.IncludedVariant.at(ii),m3iSystemConstantValueSets);
            end
        end

        function m3iPostBuildVariantCriterionValueSets=getPostBuildVariantCriterionValueSetsFromPredefinedVariant(m3iObj,m3iPostBuildVariantCriterionValueSets)
            for ii=1:m3iObj.PostBuildVariantCriterionValueSet.size()
                m3iPostBuildVariantCriterionValueSets=[m3iPostBuildVariantCriterionValueSets,m3iObj.PostBuildVariantCriterionValueSet.at(ii)];%#ok<AGROW>
            end
            for ii=1:m3iObj.IncludedVariant.size()
                m3iPostBuildVariantCriterionValueSets=...
                autosar.api.Utils.getPostBuildVariantCriterionValueSetsFromPredefinedVariant(...
                m3iObj.IncludedVariant.at(ii),m3iPostBuildVariantCriterionValueSets);
            end
        end

        function pbCriterionsValueMap=createPostBuildVariantCriterionMap(m3iModel,predefinedVariant,postBuildVariantCriterionValueSets)
            m3iPostBuildVariantCriterionValueSet={};
            if isempty(predefinedVariant)
                if isempty(postBuildVariantCriterionValueSets)

                    m3iObjSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
                    Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet.MetaClass,...
                    true,false);
                    if m3iObjSeq.size()>0
                        for ii=1:m3iObjSeq.size()
                            m3iPostBuildVariantCriterionValueSet=[m3iPostBuildVariantCriterionValueSet,m3iObjSeq.at(ii)];%#ok<AGROW>
                        end
                    end
                else

                    for ii=1:numel(postBuildVariantCriterionValueSets)
                        m3iObjSeq=autosar.mm.Model.findObjectByName(m3iModel,postBuildVariantCriterionValueSets{ii});
                        if m3iObjSeq.size()>0
                            if isa(m3iObjSeq.at(1),'Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet')
                                m3iPostBuildVariantCriterionValueSet=[m3iPostBuildVariantCriterionValueSet,m3iObjSeq.at(1)];%#ok<AGROW>
                            elseif isa(m3iObjSeq.at(1),'Simulink.metamodel.arplatform.variant.SystemConstValueSet')

                            else
                                DAStudio.error('autosarstandard:api:invalidElementPath',postBuildVariantCriterionValueSets{ii},'PostBuildVariantCriterionValueSet','Post-Build Variant Criterions')
                            end
                        else
                            DAStudio.error('autosarstandard:api:invalidElementPath',postBuildVariantCriterionValueSets{ii},'PostBuildVariantCriterionValueSet','Post-Build Variant Criterions')
                        end
                    end
                end
            else

                m3iObjSeq=autosar.mm.Model.findObjectByName(m3iModel,predefinedVariant);
                if m3iObjSeq.size()>0
                    m3iPredefinedVariant=m3iObjSeq.at(1);
                    if~isa(m3iPredefinedVariant,'Simulink.metamodel.arplatform.variant.PredefinedVariant')
                        DAStudio.error('autosarstandard:api:invalidElementPath',predefinedVariant,'PredefinedVariant','PostBuildVariantCriterions')
                    else
                        m3iPostBuildVariantCriterionValueSet=...
                        autosar.api.Utils.getPostBuildVariantCriterionValueSetsFromPredefinedVariant(m3iPredefinedVariant,m3iPostBuildVariantCriterionValueSet);
                    end
                else
                    DAStudio.error('autosarstandard:api:invalidElementPath',predefinedVariant,'PredefinedVariant','PostBuildVariantCriterions')
                end
            end
            pbCriterionsValueMap=autosar.api.Utils.evaluatePostBuildCriterionValues(m3iPostBuildVariantCriterionValueSet);
        end

        function sysConstsValueMap=createSystemConstantMap(m3iModel,predefinedVariant,systemConstValueSets)
            m3iSystemConstantValueSets={};
            if isempty(predefinedVariant)
                if isempty(systemConstValueSets)

                    m3iObjSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
                    Simulink.metamodel.arplatform.variant.SystemConstValueSet.MetaClass,...
                    true,false);
                    if m3iObjSeq.size()>0
                        for ii=1:m3iObjSeq.size()
                            m3iSystemConstantValueSets=[m3iSystemConstantValueSets,m3iObjSeq.at(ii)];%#ok<AGROW>
                        end
                    end
                else

                    for ii=1:numel(systemConstValueSets)
                        m3iObjSeq=autosar.mm.Model.findObjectByName(m3iModel,systemConstValueSets{ii});
                        if m3iObjSeq.size()>0
                            if isa(m3iObjSeq.at(1),'Simulink.metamodel.arplatform.variant.SystemConstValueSet')
                                m3iSystemConstantValueSets=[m3iSystemConstantValueSets,m3iObjSeq.at(1)];%#ok<AGROW>
                            elseif isa(m3iObjSeq.at(1),'Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet')

                            else
                                DAStudio.error('autosarstandard:api:invalidElementPath',systemConstValueSets{ii},'SystemConstValueSet','System Constants')
                            end
                        else
                            DAStudio.error('autosarstandard:api:invalidElementPath',systemConstValueSets{ii},'SystemConstValueSet','System Constants')
                        end
                    end
                end
            else

                m3iObjSeq=autosar.mm.Model.findObjectByName(m3iModel,predefinedVariant);
                if m3iObjSeq.size()>0
                    m3iPredefinedVariant=m3iObjSeq.at(1);
                    if~isa(m3iPredefinedVariant,'Simulink.metamodel.arplatform.variant.PredefinedVariant')
                        DAStudio.error('autosarstandard:api:invalidElementPath',predefinedVariant,'PredefinedVariant','System Constants')
                    else
                        m3iSystemConstantValueSets=...
                        autosar.api.Utils.getSystemConstValueSetsFromPredefinedVariant(m3iPredefinedVariant,m3iSystemConstantValueSets);
                    end
                else
                    DAStudio.error('autosarstandard:api:invalidElementPath',predefinedVariant,'PredefinedVariant','System Constants')
                end
            end
            sysConstsValueMap=autosar.api.Utils.evaluateSystemConstValues(m3iSystemConstantValueSets);
        end

        function sysConstsValueMap=createSystemConstantMapFromPDV(m3iPredefinedVariant)
            m3iSystemConstantValueSets=autosar.api.Utils.getSystemConstValueSetsFromPredefinedVariant(...
            m3iPredefinedVariant,{});
            sysConstsValueMap=autosar.api.Utils.evaluateSystemConstValues(m3iSystemConstantValueSets);
        end

        function pbVarCritsValueMap=createPostBuildVariantCriterionMapFromPDV(m3iPredefinedVariant)
            m3iPostBuildVariantCriterionValueSets=autosar.api.Utils.getPostBuildVariantCriterionValueSetsFromPredefinedVariant(...
            m3iPredefinedVariant,{});
            pbVarCritsValueMap=autosar.api.Utils.evaluatePostBuildCriterionValues(m3iPostBuildVariantCriterionValueSets);
        end

        function createSystemConstantParams(modelName,m3iSystemConstValueSet)
            sysConstsValueMap=autosar.api.Utils.evaluateSystemConstValues(m3iSystemConstValueSet);
            keys=sysConstsValueMap.keys();
            values=sysConstsValueMap.values();
            for ii=1:numel(keys)
                slParamName=keys{ii};
                [sysConExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,slParamName);
                if sysConExists&&~autosar.mm.sl2mm.variant.Utils.isSystemConstant(slObj)
                    sysConExists=false;
                end
                slParam=AUTOSAR.Parameter;
                slParam.CoderInfo.StorageClass='Custom';
                slParam.CoderInfo.CustomStorageClass='SystemConstant';
                value=values{ii};
                if numel(value)>1
                    value=value(1);
                end
                slParam.Value=value;



                if sysConExists
                    slParam.DataType=slObj.DataType;
                else
                    slParam.DataType='int32';
                end

                assigninGlobalScope(modelName,slParamName,slParam);
            end
        end

        function slObj=createParameterObject(parameterRole,port,dataElement)
            switch parameterRole
            case 'PortParameter'
                slObj=AUTOSAR.Parameter;
                slObj.CoderInfo.StorageClass='Custom';
                slObj.CoderInfo.CustomStorageClass='CalPrm';
                slObj.CoderInfo.CustomAttributes.PortName=port;
                slObj.CoderInfo.CustomAttributes.ElementName=dataElement;
            case 'PerInstance'
                slObj=AUTOSAR.Parameter;
                slObj.CoderInfo.StorageClass='Custom';
                slObj.CoderInfo.CustomStorageClass='InternalCalPrm';
                slObj.CoderInfo.CustomAttributes.PerInstanceBehavior='Each instance of the Software Component has its own copy of the parameter';
            case 'Shared'
                slObj=AUTOSAR.Parameter;
                slObj.CoderInfo.StorageClass='Custom';
                slObj.CoderInfo.CustomStorageClass='InternalCalPrm';
                slObj.CoderInfo.CustomAttributes.PerInstanceBehavior='Parameter shared by all instances of the Software Component';
            case 'ConstantMemory'
                slObj=AUTOSAR4.Parameter;
                slObj.CoderInfo.StorageClass='ExportedGlobal';
                slObj.CoderInfo.Identifier=dataElement;
            case 'Auto'
                slObj=AUTOSAR4.Parameter;
                slObj.CoderInfo.StorageClass='Auto';
            end
        end

        function output=getLookupMapping(modelName,slParam)


            output.success=1;
            output.message='';


            try
                modelMapping=autosar.api.Utils.modelMapping(modelName);
                slLUT=modelMapping.LookupTables.findobj('LookupTableName',slParam);
                if isempty(slLUT)

                    output.ARParameterData=[];
                else

                    output.ARParameterData=slLUT.MappedTo.Parameter;
                end
            catch e
                output.success=0;
                output.message=e.getReport;
            end
        end

        function setInternalDataProperties(modelName,mappingObj,MappedTo,isVariable,argParser)
            mappedTo=mappingObj.MappedTo;
            if isVariable
                mappedTo.VariableType=MappedTo;
            else
                mappedTo.ParameterType=MappedTo;
            end
            if~strcmp(MappedTo,DAStudio.message('coderdictionary:mapping:NoMapping'))
                params=argParser.Unmatched;
                if~isempty(fields(params))
                    instSpecificPropertyNames=fieldnames(params);
                    instSpecificPropertyValues=struct2cell(params);
                    modelH=get_param(modelName,'Handle');
                    for ii=1:numel(instSpecificPropertyNames)
                        propertyName=instSpecificPropertyNames{ii};
                        propertyName=validatestring(propertyName,...
                        mappedTo.getPerInstancePropertyNames(isVariable));
                        Simulink.CodeMapping.setPerInstancePropertyValue(modelH,mappingObj,'MappedTo',propertyName,instSpecificPropertyValues{ii});
                    end
                end
            end
        end
        function mapObj=findMappingObjMappedToRunnable(mappingRoot,runnableName)



            mapObj=[];
            mappingCategoryNames=autosar.ui.configuration.PackageString.MappingObjWithRunnables;

            for categoryName=mappingCategoryNames
                mapObjList=mappingRoot.(categoryName{1});
                for curMapObj=mapObjList
                    if curMapObj.isvalid()&&...
                        isa(curMapObj.MappedTo,autosar.ui.configuration.PackageString.RunnableClass)&&...
                        strcmp(curMapObj.MappedTo.Runnable,runnableName)
                        mapObj=curMapObj;
                        break;
                    end
                end
                if~isempty(mapObj)
                    break;
                end
            end
        end




        function uniqueMdlName=getUniqueModelName(mdlName)

            startName=mdlName;
            uniqueMdlName=startName;
            count=1;
            while exist([uniqueMdlName,'.slx'],'file')||...
                autosar.api.Utils.isModelInMemory(uniqueMdlName)
                uniqueMdlName=strcat(startName,'_',num2str(count));
                count=count+1;
            end
        end


        function uniqueStrings=makeUniqueCaseInsensitiveStrings(inStr,excludes,maxStringLength)
            lowerUniqueStrings=matlab.lang.makeUniqueStrings(lower(inStr),lower(excludes),maxStringLength);
            if~strcmpi(lowerUniqueStrings,inStr)
                uniqueStrings=lowerUniqueStrings;
            else
                uniqueStrings=matlab.lang.makeUniqueStrings(inStr,excludes,maxStringLength);
            end
        end


        function newName=createUniqueNameInSeq(modelName,defaultName,path)
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iObj=autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath(m3iModel,path);
            excludeNames=m3i.mapcell(@(x)x.Name,m3iObj.containeeM3I);
            maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
            newName=autosar.api.Utils.makeUniqueCaseInsensitiveStrings(...
            arxml.arxml_private('p_create_aridentifier',defaultName,maxShortNameLength),...
            excludeNames,maxShortNameLength);
        end

        function isEqual=areStructsEqual(structA,structB)



            isEqual=true;
            if~isequal(structA,structB)
                isEqual=false;
                return;
            end

            fieldNamesA=fieldnames(structA);
            fieldnamesB=fieldnames(structB);
            valuesA=struct2cell(structA);
            valuesB=struct2cell(structB);

            if~isequal(fieldNamesA,fieldnamesB)


                isEqual=false;
                return;
            end


            for ii=1:numel(valuesA)
                if isstruct(valuesA{ii})
                    isEqual=autosar.api.Utils.areStructsEqual(valuesA{ii},valuesB{ii});
                else
                    isEqual=isequal(class(valuesA{ii}),class(valuesB{ii}));
                end
                if~isEqual
                    return;
                end
            end
        end
    end

    methods(Static=true,Access='private')
        function sysConstsValueMap=evaluateSystemConstValues(m3iSystemConstValueSet)
            sysConstsValueMap=containers.Map();






            for ii=1:numel(m3iSystemConstValueSet)
                sysConstValue=m3iSystemConstValueSet(ii).SysConstValue;
                for jj=1:sysConstValue.size()
                    m3iData=sysConstValue.at(jj);
                    systemConstant=m3iData.SysConst;
                    name=systemConstant.Name;
                    if m3iData.ValueVariationPoint.isEmpty()
                        value=double(m3iData.Value);
                        if sysConstsValueMap.isKey(name)
                            prevValue=sysConstsValueMap(name);
                            if isempty(find(prevValue==value))%#ok<EFIND>
                                sysConstsValueMap(name)=[prevValue,value];
                            end
                        else
                            sysConstsValueMap(name)=value;
                        end
                    end
                end
            end










            for ii=1:numel(m3iSystemConstValueSet)
                sysConstValue=m3iSystemConstValueSet(ii).SysConstValue;
                for jj=1:sysConstValue.size()
                    m3iData=sysConstValue.at(jj);
                    systemConstant=m3iData.SysConst;
                    name=systemConstant.Name;
                    if~m3iData.ValueVariationPoint.isEmpty()
                        fexpr=autosar.mm.util.FormulaExpression.createFromARXML(m3iData.ValueVariationPoint.front,sysConstsValueMap);
                        sysConstsValueMap(name)=fexpr.evaluated;
                    end
                end
            end
        end

        function postBuildCriterionValueMap=evaluatePostBuildCriterionValues(m3iPostBuildCriterionValueSet)
            postBuildCriterionValueMap=containers.Map();






            for ii=1:numel(m3iPostBuildCriterionValueSet)
                pbCritValue=m3iPostBuildCriterionValueSet(ii).PostBuildVariantCriterionValue;
                for jj=1:pbCritValue.size()
                    m3iData=pbCritValue.at(jj);
                    pbCrit=m3iData.VariantCriterion;
                    name=pbCrit.Name;
                    if m3iData.ValueVariationPoint.isEmpty
                        value=double(m3iData.Value);
                        if postBuildCriterionValueMap.isKey(name)
                            prevValue=postBuildCriterionValueMap(name);
                            if isempty(find(prevValue==value))%#ok<EFIND>
                                postBuildCriterionValueMap(name)=[prevValue,value];
                            end
                        else
                            postBuildCriterionValueMap(name)=value;
                        end
                    end
                end
            end
        end

        function bdExist=isModelInMemory(mdlName)

            loadedMdl=find_system('type','block_diagram');
            bdExist=any(strcmp(mdlName,loadedMdl));
        end
    end
end

function ret=isValidMove(arRoot,srcPkg,destPkg)
    ret=true;
    if isempty(srcPkg)||isempty(destPkg)||strcmp(srcPkg,destPkg)
        ret=false;
        return;
    end
    m3iSrcPkg=autosar.mm.Model.getArPackage(arRoot,srcPkg);







    if isempty(m3iSrcPkg)||any(strcmp(m3iSrcPkg.category,{'BLUEPRINT','STANDARD'}))
        ret=false;
        return;
    end
end
function ret=shouldMoveElements(srcPkg,destPkg,category,moveElementsMode)
    if strcmp(moveElementsMode,'Alert')
        try
            message=DAStudio.message('autosarstandard:ui:movePackageableElementsAlert',category,srcPkg,destPkg);
            choice=questdlg(message,DAStudio.message('autosarstandard:ui:movePackageableElementsAlertDlgTitle'),...
            'OK','Cancel','OK');
            switch choice
            case 'Cancel'
                ret=false;
            otherwise
                ret=true;
            end
        catch
        end
    elseif strcmp(moveElementsMode,'All')
        ret=true;
    elseif strcmp(moveElementsMode,'Default')
        ret=false;
    else
        ret=false;
    end
end



function addPrototypControlHelper(modelName,mappingObjs)
    for i=1:length(mappingObjs)
        runnableName=mappingObjs(i).MappedTo.Runnable;
        if isempty(runnableName)



            return;
        end
        m3iRunnableObj=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
        modelName,runnableName);
        if isempty(m3iRunnableObj)

            return;
        end
        if~isempty(m3iRunnableObj.symbol)
            mappingObjs(i).MappedTo.RunnableSymbol=m3iRunnableObj.symbol;
        else
            mappingObjs(i).MappedTo.RunnableSymbol=m3iRunnableObj.Name;
        end
    end
end

function isNvmPim=isNvmRwBlockPim(blkPath,m3iArg)



    isNvmPim=false;

    [isMappedToNvm,nvmServiceName]=autosar.api.Utils.isMappedToNvmService(blkPath);
    if(isMappedToNvm)


        switch nvmServiceName
        case 'WriteBlock'
            isNvmPim=m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In;
        case{'ReadBlock','RestoreBlockDefaults'}


            isNvmPim=m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out;
        otherwise
            assert(false,'Unhandled NvM service name %s',nvmServiceName);
        end
    end
end






function cImpl=getBlockCImpl(m3iOp,blk)
    cImpl=RTW.CImplementation;
    cImpl.Return=[];

    if~m3iOp.isvalid()
        return
    end


    [~,outparam]=autosar.validation.ClientServerValidator.getBlockInOutParams(blk);


    [isCompatible,errIdx,msg]=autosar.validation.ClientServerValidator.checkArguments(m3iOp,...
    blk);
    if~isCompatible
        if(~isempty(msg))
            throw(msg);
        else
            return;
        end
    end


    allArgs=[];
    for j=1:m3iOp.Arguments.size
        tmpArg=RTW.Argument;
        tmpArg.Name=m3iOp.Arguments.at(j).Name;
        tmpArg.Type=embedded.numerictype;
        if m3iOp.Arguments.at(j).Direction==...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In
            tmpArg.IOType='RTW_IO_INPUT';
            if isNvmRwBlockPim(blk,m3iOp.Arguments.at(j))
                tmpArg.Type=embedded.pointertype;
                tmpArg.Type.BaseType=embedded.voidtype;
                tmpArg.Type.BaseType.ReadOnly=true;
            elseif autosar.api.Utils.isArraySizeOne(m3iOp.Arguments.at(j).Type)

                tmpArg.Type=embedded.matrixtype;
                tmpArg.Type.Dimensions=1;
                tmpArg.Type.ArrSizeOne=true;
                tmpArg.Type.ReadOnly=false;
                tmpArg.Type.BaseType=embedded.numerictype;
                tmpArg.Type.BaseType.ReadOnly=true;
            end
        elseif m3iOp.Arguments.at(j).Direction==...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out
            tmpArg.IOType='RTW_IO_OUTPUT';
            if isNvmRwBlockPim(blk,m3iOp.Arguments.at(j))
                tmpArg.Type=embedded.pointertype;
                tmpArg.Type.BaseType=embedded.voidtype;
            elseif autosar.api.Utils.isArraySizeOne(m3iOp.Arguments.at(j).Type)

                tmpArg.Type=embedded.matrixtype;
                tmpArg.Type.Dimensions=1;
                tmpArg.Type.ArrSizeOne=true;
                tmpArg.Type.ReadOnly=false;
                tmpArg.Type.BaseType=embedded.numerictype;
                tmpArg.Type.BaseType.ReadOnly=false;
            end
        elseif m3iOp.Arguments.at(j).Direction==...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut
            tmpArg.IOType='RTW_IO_INPUT_OUTPUT';
            if autosar.api.Utils.isArraySizeOne(m3iOp.Arguments.at(j).Type)

                tmpArg.Type=embedded.matrixtype;
                tmpArg.Type.Dimensions=1;
                tmpArg.Type.ArrSizeOne=true;
                tmpArg.Type.ReadOnly=false;
                tmpArg.Type.BaseType=embedded.numerictype;
                tmpArg.Type.BaseType.ReadOnly=false;
            end
        elseif m3iOp.Arguments.at(j).Direction==...
            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error
            tmpArg.IOType='RTW_IO_OUTPUT';
            tmpArg.Type=embedded.numerictype;
            tmpArg.Name=[num2str(errIdx),':',outparam{errIdx}];
            cImpl.Return=tmpArg;
            continue;
        end
        allArgs=[allArgs;tmpArg];%#ok<AGROW>
    end
    cImpl.Arguments=allArgs;
end







