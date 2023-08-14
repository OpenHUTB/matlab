classdef Utils<handle




    methods(Static,Access=public)
        function result=isM3IComposition(m3iObj)


            result=~isempty(m3iObj)&&...
            isa(m3iObj,'Simulink.metamodel.arplatform.composition.CompositionComponent')&&...
            m3iObj.isvalid();
        end

        function isComposition=isM3ICompositionPrototype(m3iCompPrototype)
            assert(isa(m3iCompPrototype,'Simulink.metamodel.arplatform.composition.ComponentPrototype'),...
            'Expected to be provided a ComponentPrototype');
            if isa(m3iCompPrototype.Type,'Simulink.metamodel.arplatform.composition.CompositionComponent')
                isComposition=true;
            else

                isComposition=false;
            end
        end

        function[isComposition,m3iComposition]=isCompositionModel(model)


            isComposition=false;
            m3iComposition=[];

            modelName=getfullname(model);

            if strcmp(get_param(modelName,'AutosarCompliant'),'on')&&...
                autosar.api.Utils.isMappedToComposition(modelName)
                m3iModel=autosar.api.Utils.m3iModel(modelName);
                dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                m3iComp=autosar.mm.Model.findChildByName(m3iModel,compQName);
                if autosar.composition.Utils.isM3IComposition(m3iComp)
                    isComposition=true;
                    m3iComposition=m3iComp;
                end
            end
        end

        function supportedComponentKinds=getSupportedComponentKinds()
            supportedComponentKinds={'Application','ComplexDeviceDriver',...
            'EcuAbstraction','SensorActuator','ServiceProxy'};
        end

        function isSupported=isAtomicComponentSupported(m3iComp)
            if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
                autosar.mm.util.MessageReporter.createWarning(...
                'autosarstandard:importer:adaptiveComponentNotSupportedInArch',...
                autosar.api.Utils.getQualifiedName(m3iComp));
                isSupported=false;
            else
                assert(isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent'),...
                'm3iComp should be AtomicComponent but it is: %s',class(m3iComp));
                isSupported=any(strcmp(m3iComp.Kind.toString(),autosar.composition.Utils.getSupportedComponentKinds()));
            end
        end

        function m3iComps=findAtomicComponents(m3iComposition,doRecursion,onlySupported)
















            narginchk(3,3);
            m3iComps=autosar.composition.Utils.findComponentsMatchingMetaClass(...
            m3iComposition,Simulink.metamodel.arplatform.component.AtomicComponent.MetaClass,doRecursion);

            if(onlySupported)
                m3iComps=m3iComps(arrayfun(@(x)autosar.composition.Utils.isAtomicComponentSupported(x),...
                m3iComps));
            end



            m3iComps=flip(m3iComps);
        end

        function m3iComps=findAdaptiveApplications(m3iComposition,doRecursion,onlySupported)
















            narginchk(3,3);
            m3iComps=autosar.composition.Utils.findComponentsMatchingMetaClass(...
            m3iComposition,Simulink.metamodel.arplatform.component.AdaptiveApplication.MetaClass,doRecursion);

            if(onlySupported)
                m3iComps=m3iComps(arrayfun(@(x)autosar.composition.Utils.isAtomicComponentSupported(x),...
                m3iComps));
            end



            m3iComps=flip(m3iComps);
        end

        function m3iComps=findCompositionComponents(m3iComposition,doRecursion)












            narginchk(2,2);
            m3iComps=autosar.composition.Utils.findComponentsMatchingMetaClass(...
            m3iComposition,Simulink.metamodel.arplatform.composition.CompositionComponent.MetaClass,doRecursion);



            m3iComps=flip(m3iComps);
        end

        function m3iComps=findComponentsMatchingMetaClass(m3iComposition,compMetaClass,doRecursion)







            narginchk(3,3);
            assert(autosar.composition.Utils.isM3IComposition(m3iComposition),...
            'm3iComposition is not a composition component.');
            assert(islogical(doRecursion),'doRecursion must be boolean');

            m3iComps=[];


            if(m3iComposition.MetaClass==compMetaClass)
                m3iComps=[m3iComps,m3iComposition];
            end


            m3iComponentPrototypes=m3iComposition.Components;
            for idx=1:m3iComponentPrototypes.size()
                m3iComponentPrototype=m3iComponentPrototypes.at(idx);
                m3iComponent=m3iComponentPrototype.Type;


                if(m3iComponent.MetaClass==compMetaClass)
                    m3iComps=[m3iComps,m3iComponent];%#ok<AGROW>
                end


                if autosar.composition.Utils.isM3IComposition(m3iComponent)&&doRecursion
                    m3iComps=[m3iComps...
                    ,autosar.composition.Utils.findComponentsMatchingMetaClass(...
                    m3iComponent,compMetaClass,doRecursion)];%#ok<AGROW>
                end
            end

            if~isempty(m3iComps)

                [~,idx]=unique({m3iComps.Name},'stable');
                m3iComps=m3iComps(idx);
            end
        end

        function m3iResult=findCompPrototypesInComposition(m3iComposition)







            assert(autosar.composition.Utils.isM3IComposition(m3iComposition),...
            'm3iComposition is not a composition component.');

            m3iResult=[];


            m3iCompProtos=m3iComposition.Components;
            for idx=1:m3iCompProtos.size()
                m3iCompProto=m3iCompProtos.at(idx);
                m3iComponent=m3iCompProto.Type;


                m3iResult=[m3iResult,m3iCompProto];%#ok<AGROW>


                if autosar.composition.Utils.isM3IComposition(m3iComponent)
                    m3iResult=[m3iResult...
                    ,autosar.composition.Utils.findCompPrototypesInComposition(...
                    m3iComponent)];%#ok<AGROW>
                end
            end
        end


        function m3iCompsOut=sortCompositionsInTopdownOrder(m3iCompsIn)
            assert(iscell(m3iCompsIn),'m3iCompsIn must be cell array');

            if length(m3iCompsIn)==1
                m3iCompsOut=m3iCompsIn;
            else
                compCountVector=cellfun(@(x)...
                length(autosar.composition.Utils.findCompositionComponents(x,true)),...
                m3iCompsIn);
                [~,sortIdx]=sort(compCountVector,'descend');
                m3iCompsOut=m3iCompsIn(sortIdx);
            end
        end

        function[isCompInArchModel,m3iComp,compBlock]=isCompTypeInArchModel(archModelName,compTypeName)




            isCompInArchModel=false;
            compBlock='';
            m3iComp=[];


            m3iModel=autosar.api.Utils.m3iModel(archModelName);
            m3iExistingComps=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.component.Component.MetaClass,true,true);
            for i=1:m3iExistingComps.size()
                if strcmp(m3iExistingComps.at(i).Name,compTypeName)
                    m3iComp=m3iExistingComps.at(i);
                    isCompInArchModel=true;
                    break;
                end
            end

            if isCompInArchModel&&nargout>2



                compBlock=find_system(getfullname(archModelName),...
                'BlockType','SubSystem','Name',compTypeName);
                if~isempty(compBlock)
                    compBlock=compBlock{1};
                end
            end
        end

        function isCompositionDomain=isModelInCompositionDomain(model)
            isCompositionDomain=autosarcore.ModelUtils.isModelInCompositionDomain(model);
        end

        function isComponent=isComponentOrCompositionBlock(blkH)
            blkH=get_param(blkH,'Handle');
            isComponent=autosar.arch.Utils.isBlock(blkH)&&...
            autosar.composition.Utils.isModelInCompositionDomain(bdroot(blkH))&&...
            (autosar.arch.Utils.isSubSystem(blkH)||autosar.arch.Utils.isModelBlock(blkH))&&...
            ~autosar.composition.Utils.isAdapterBlock(blkH);
        end

        function isComponent=isCompBlockNonLinked(blkH)
            isComponent=autosar.composition.Utils.isComponentOrCompositionBlock(blkH)&&...
            autosar.arch.Utils.isSubSystem(blkH);
        end


        function isComponent=isComponentBlock(blkH)
            blkH=get_param(blkH,'Handle');
            isComponent=autosar.composition.Utils.isComponentOrCompositionBlock(blkH)&&...
            ~autosar.composition.Utils.isCompositionBlock(blkH)&&...
            ~autosar.composition.Utils.isAdapterBlock(blkH);


            if isComponent
                isBSWComponent=autosar.bsw.ServiceComponent.isBswServiceComponent(blkH);
                isComponent=isComponent&&~isBSWComponent;
            end
        end

        function isAdapter=isAdapterBlock(blkH)
            blkH=get_param(blkH,'Handle');
            isAdapter=autosar.arch.Utils.isSubSystem(blkH)&&...
            (strcmp(get_param(blkH,'SimulinkSubDomain'),'ArchitectureAdapter'));
        end

        function isComposition=isCompositionBlock(blkH)
            blkH=get_param(blkH,'Handle');
            isComposition=false;

            if~autosar.composition.Utils.isComponentOrCompositionBlock(blkH)
                return;
            end


            m3iCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(blkH);
            if m3iCompProto.isvalid()
                if m3iCompProto.Type.isvalid

                    isComposition=m3iCompProto.Type.MetaClass==...
                    Simulink.metamodel.arplatform.composition.CompositionComponent.MetaClass;
                    return;
                end
            end
        end

        function tf=isEmptyCompositionBlock(blkH)
            tf=autosar.composition.Utils.isCompositionBlock(blkH)&&...
            (length(find_system(blkH))==1);
        end

        function tf=isEmptyBlockDiagram(modelH)
            tf=(length(find_system(modelH))==1);
        end

        function[isLinked,refMdl]=isCompBlockLinked(blkH)
            refMdl='';
            isLinked=strcmp(get_param(blkH,'BlockType'),'ModelReference');
            if isLinked
                refMdl=get_param(blkH,'ModelName');
            end
        end

        function isCompositeInport=isCompositeInportBlock(blkH)
            isCompositeInport=...
            strcmp(get_param(blkH,'BlockType'),'Inport')&&...
            strcmp(get_param(blkH,'IsComposite'),'on');
        end

        function isCompositeOutport=isCompositeOutportBlock(blkH)
            isCompositeOutport=...
            strcmp(get_param(blkH,'BlockType'),'Outport')&&...
            strcmp(get_param(blkH,'IsComposite'),'on');
        end

        function isCompositePort=isCompositePortBlock(blkH)
            isCompositePort=(autosar.composition.Utils.isCompositeInportBlock(blkH)||...
            autosar.composition.Utils.isCompositeOutportBlock(blkH))&&...
            ~autosar.composition.Utils.isAdapterBlock(get_param(blkH,'Parent'));
        end



        function isReceiverPort=isDataReceiverPort(blkH)
            isReceiverPort=autosar.composition.Utils.isCompositeInportBlock(blkH);
        end



        function isSenderPort=isDataSenderPort(blkH)
            isSenderPort=autosar.composition.Utils.isCompositeOutportBlock(blkH);
        end

        function createDefaultCompositionMapping(modelName)



            set_param(modelName,...
            'SystemTargetFile','autosar.tlc',...
            'SolverType','Fixed-step',...
            'Solver','FixedStepDiscrete',...
            'EnableMultiTasking','on',...
            'AllowMultiTaskInputOutput','on',...
            'AutoInsertRateTranBlk','on',...
            'InsertRTBMode','Never (minimum delay)'...
            );

            autosar.api.create(modelName,'init',...
            'ComponentType','CompositionComponent');



            m3iModel=autosar.api.Utils.m3iModel(modelName);
            t=M3I.Transaction(m3iModel);
            autosar.mm.util.XmlOptionsDefaultPackages.setAllEmptyXmlOptionsToDefault(modelName);

            arRoot=m3iModel.RootPackage.front;
            arRoot.setExternalToolInfo(M3I.ExternalToolInfo('M3IModelForArchitectureModel','1'));
            t.commit;

            set_param(modelName,'Dirty','off');
        end


        function m3iObj=findM3IObjectForCompositionElement(sysH)
            m3iObj=M3I.ImmutableObject;
            if strcmp(get_param(sysH,'type'),'block_diagram')
                m3iObj=autosar.api.Utils.m3iMappedComponent(sysH);
            elseif strcmp(get_param(sysH,'type'),'port')
                portNum=num2str(get(sysH,'PortNumber'));
                parentBlk=get_param(sysH,'Parent');
                if any(strcmp(get_param(parentBlk,'BlockType'),{'Inport','Outport'}))
                    portBlk=parentBlk;
                else
                    assert(autosar.composition.Utils.isComponentOrCompositionBlock(parentBlk));
                    if strcmp(get_param(sysH,'PortType'),'inport')
                        portType='Inport';
                    else
                        portType='Outport';
                    end
                    portBlk=find_system(parentBlk,'SearchDepth',1,...
                    'BlockType',portType,'Port',portNum);
                    portBlk=portBlk{1};
                end

                m3iObj=autosar.composition.Utils.findM3IObjectForCompositionElement(portBlk);
            elseif autosar.composition.Utils.isComponentOrCompositionBlock(sysH)
                m3iObj=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(sysH);
            elseif autosar.composition.Utils.isCompositePortBlock(sysH)
                m3iObj=autosar.composition.Utils.findM3IPortForCompositePort(sysH);
            end
        end


        function m3iPort=findM3IPortForCompositePort(blkH)
            assert(autosar.composition.Utils.isCompositePortBlock(blkH),...
            '%s is not a composite port block',getfullname(blkH));

            m3iSWC=autosar.composition.Utils.getM3ICompFromPortBlock(blkH);
            portName=get_param(blkH,'PortName');
            m3iPort=autosar.composition.Utils.findM3IPortWithName(m3iSWC,portName);
        end


        function m3iPort=findM3IPortForSignalPort(blkH)
            assert(~autosar.composition.Utils.isCompositePortBlock(blkH),...
            '%s is not a signal port block',getfullname(blkH));

            m3iSWC=autosar.composition.Utils.getM3ICompFromPortBlock(blkH);
            portName=get_param(blkH,'PortName');
            m3iPort=autosar.composition.Utils.findM3IPortWithName(m3iSWC,portName);
        end


        function m3iPort=findM3IPortWithName(m3iSWC,ARPortName)
            m3iPort=M3I.ImmutableObject;
            if m3iSWC.isvalid()
                m3iPort=autosar.composition.Utils.findM3IObjectWithName(...
                m3iSWC,ARPortName);
            end
        end



        function m3iComposition=findM3ICompositionParentForCompBlock(blkH)
            m3iRootComposition=autosar.api.Utils.m3iMappedComponent(bdroot(blkH));
            m3iComposition=n_searchForCompositionParent(m3iRootComposition,getfullname(blkH));

            function m3iCompositionParent=n_searchForCompositionParent(m3iComposition,blkRoute)
                route=regexp(blkRoute,'/','split');
                if length(route)>2


                    m3iCompPrototype=autosar.composition.Utils.findM3ICompPrototypeWithName(...
                    m3iComposition,route{2});
                    newBlkRoute=strcat(route(2:end),'/');
                    newBlkRoute=[newBlkRoute{:}];
                    newBlkRoute=newBlkRoute(1:end-1);
                    m3iCompositionParent=n_searchForCompositionParent(m3iCompPrototype.Type,newBlkRoute);
                else
                    m3iCompositionParent=m3iComposition;
                end
            end
        end



        function m3iCompPrototype=findM3ICompPrototypeForCompBlock(blkH)
            m3iCompositionParent=autosar.composition.Utils.findM3ICompositionParentForCompBlock(blkH);
            compPrototypeName=get_param(blkH,'Name');
            m3iCompPrototype=autosar.composition.Utils.findM3ICompPrototypeWithName(...
            m3iCompositionParent,compPrototypeName);
        end


        function m3iCompPrototype=findM3ICompPrototypeWithName(m3iComposition,compPrototypeName)
            m3iCompPrototype=autosar.composition.Utils.findM3IObjectWithName(...
            m3iComposition,compPrototypeName);
        end


        function m3iComp=getM3ICompFromPortBlock(blkH)
            dstModelH=get_param(bdroot(blkH),'Handle');
            dstParent=get_param(get_param(blkH,'Parent'),'Handle');
            isBlockAtRootLevel=isequal(dstModelH,dstParent);
            if isBlockAtRootLevel
                m3iComp=autosar.api.Utils.m3iMappedComponent(dstModelH);
            else
                m3iCompPrototype=...
                autosar.composition.Utils.findM3ICompPrototypeForCompBlock(dstParent);
                m3iComp=m3iCompPrototype.Type;
            end
        end

        function m3iObj=findM3IObjectWithName(m3iParent,childName)
            m3iObj=M3I.ImmutableObject;
            m3iObjSeq=autosar.mm.Model.findObjectByName(m3iParent,childName);
            if m3iObjSeq.size()==1
                m3iObj=m3iObjSeq.at(1);
            end
        end



        function compBlocks=findCompBlocks(parentSys)
            compBlocks={};



            blocks=find_system(parentSys,'SearchDepth',1,'type','block');
            blocks=blocks(~strcmp(blocks,parentSys));
            for ii=1:length(blocks)
                blk=blocks{ii};
                if autosar.composition.Utils.isComponentBlock(blk)||...
                    autosar.composition.Utils.isCompositionBlock(blk)
                    compBlocks{end+1}=blk;%#ok<AGROW>
                else


                end
            end


            compBlocks=setdiff(compBlocks,autosar.bsw.ServiceComponent.find(parentSys));
        end

        function compositeInports=findCompositeInports(parentSys)
            compositeInports=find_system(parentSys,'SearchDepth',1,'blocktype',...
            'Inport','IsComposite','on');
        end

        function compositeOutports=findCompositeOutports(parentSys)
            compositeOutports=find_system(parentSys,'SearchDepth',1,'blocktype',...
            'Outport','IsComposite','on');
        end

        function adapterBlocks=findAdapterBlocks(parentSys)
            adapterBlocks=find_system(parentSys,'SearchDepth',1,'blocktype',...
            'SubSystem','SimulinkSubDomain','ArchitectureAdapter');
        end




        function addComponentUsingEditor(blockPath)
            autosar.composition.Utils.addCompUsingEditor(blockPath,false);
        end




        function addCompositionUsingEditor(blockPath)
            autosar.composition.Utils.addCompUsingEditor(blockPath,true);
        end

        function isArchModel=isAUTOSARArchModel(m3iModel)
            m3iRoot=m3iModel.rootModel.RootPackage.front();
            isArchModelToolInfo=m3iRoot.getExternalToolInfo('M3IModelForArchitectureModel').externalId;
            isArchModel=strcmp(isArchModelToolInfo,'1');
        end
    end

    methods(Static,Access=private)
        function addCompUsingEditor(blockPath,isComposition)



            assert((ischar(blockPath)||isstring(blockPath))&&...
            contains(blockPath,'/'),'invalid block Path');
            [model,pathFromModel]=strtok(blockPath,'/');
            pathFromModel=pathFromModel(2:end);
            assert(autosar.composition.Utils.isModelInCompositionDomain(model),...
            '%s is not an AUTOSAR architecture model',model);


            separatorIdx=strfind(blockPath,'/');
            parentSys=blockPath(1:separatorIdx-1);
            open_system(parentSys);
            editor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(parentSys,'handle'));
            assert(~isempty(editor),'Editor is empty for %s',parentSys);


            if isComposition
                SLM3I.Util.createNewComposition(editor,[110,145,120,100],pathFromModel);
            else
                SLM3I.Util.createNewComponent(editor,[110,145,120,100],pathFromModel);
            end


            editor.clearSelection();
        end
    end
end


