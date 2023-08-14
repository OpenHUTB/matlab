classdef ComponentToImplSubsystemConverter<handle








    properties(Access=protected)
        BlockHandle;
        BDHandle;
        ValidationPassed;
        SSBlockHandle;
        portPlacementSchema;
        subPorts;
        prthdls;
    end

    properties(Access=private)
        archPluginTxn;
        archCache;
    end

    methods(Access=public)
        function obj=ComponentToImplSubsystemConverter(blkH)

            assert(ishandle(blkH));


            obj.BlockHandle=blkH;


            obj.BDHandle=get_param(bdroot(blkH),'Handle');


            obj.SSBlockHandle=[];
        end
    end

    methods(Sealed,Access=public)
        function blockH=convertComponentToImpl(obj)

            blockH=obj.convert();
        end

        function blockH=convert(obj)
            blockH=[];%#ok<NASGU>
            try

                obj.runValidationChecks();
            catch ME
                rethrow(ME);
            end

            obj.ValidationPassed=true;



            prunerDisabler=systemcomposer.internal.ScopedUnconnectedBusPortBlockPrunerDisabler(get_param(get_param(obj.BlockHandle,'Parent'),'Handle'));

            try

                obj.preDisableSimulinkListener();


                obj.disableSimulinkListener();


                obj.cacheConnectionsBeforeDelete();


                obj.deleteConnectedLines();


                obj.preReplaceBlock();


                blockH=obj.replaceBlock();
                obj.SSBlockHandle=blockH;


                obj.postReplaceBlock();


                obj.enableSimulinkListener();


                obj.postEnableSimulinkListener();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);


                prunerDisabler.delete();

            catch ME

                blockH=[];%#ok<NASGU>


                prunerDisabler.delete();

                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=private)
        function runValidationChecks(obj)

            element=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            assert(isa(element,'systemcomposer.architecture.model.design.Component'));



            if~Simulink.internal.isArchitectureModel(bdroot(obj.BlockHandle),'Architecture')
                error('SystemArchitecture:API:InModelSLBehaviorNotSupportedSW',...
                DAStudio.message('SystemArchitecture:API:InModelSLBehaviorNotSupportedSW'));
            end

            arch=element.getArchitecture;


            if(element.isReferenceComponent||element.isImplComponent)
                obj.ValidationPassed=false;
                if element.isStateflowComponent
                    msgObj=message('SystemArchitecture:API:ComponentAlreadyBehavior');
                    exception=MException('systemcomposer:API:ComponentAlreadyBehavior',...
                    msgObj.getString);
                    throw(exception);
                else
                    msgObj=message('SystemArchitecture:API:ComponentAlreadyReference');
                    exception=MException('systemcomposer:API:ComponentAlreadyReference',...
                    msgObj.getString);
                    throw(exception);
                end
            end


            if~isempty(arch.getComponents)
                obj.ValidationPassed=false;
                error('SystemArchitecture:studio:ComponentNotLeaf',...
                DAStudio.message('SystemArchitecture:studio:ComponentNotLeaf'));
            end
        end

        function preDisableSimulinkListener(obj)

            obj.portPlacementSchema=get_param(obj.BlockHandle,'PortSchema');
        end

        function disableSimulinkListener(obj)


            obj.archPluginTxn=systemcomposer.internal.arch.internal.ArchitecturePluginTransaction(get_param(obj.BDHandle,'Name'));
        end

        function cacheConnectionsBeforeDelete(obj)

            obj.archCache=systemcomposer.internal.arch.internal.ComponentConnectionCache(obj.BlockHandle);
        end

        function deleteConnectedLines(obj)
            systemcomposer.internal.arch.internal.ZCUtils.DeleteConnectedLines(obj.BlockHandle);
        end

        function preReplaceBlock(obj)
            slreq.utils.onHierarchyChange('prechange',obj.BlockHandle);



            SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(obj.BlockHandle,SimulinkSubDomainMI.SimulinkSubDomainEnum.Simulink);



            comp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            comp.setDefinition(systemcomposer.architecture.model.core.DefinitionType.BEHAVIOR);
        end


        function newBlockH=replaceBlock(obj)


            srcBlkName=get_param(obj.BlockHandle,'Name');








            parentBlock=get_param(obj.BlockHandle,'Parent');
            newBlockH=add_block(obj.BlockHandle,[parentBlock,'/tmw_internalBlockName'],'MakeNameUnique','on');

            sidspace=get_param(bdroot(obj.BlockHandle),'SIDSpace');
            sidspace.swapSID(obj.BlockHandle,newBlockH);
            delete_block(obj.BlockHandle);
            set_param(newBlockH,'Name',srcBlkName);
        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.SSBlockHandle)&&ishandle(obj.SSBlockHandle));
            obj.archCache.restoreComponentSIDBridgeMapping(obj.SSBlockHandle);

            bridgeData=obj.archCache.bridgeData;


            function updateMappingForCacheStructure(cacheStruct)
                if~isempty(cacheStruct)
                    for i=1:1:numel(cacheStruct)
                        oldPortSID=string(cacheStruct(1,i).PortSID);
                        newPortHdl=obj.findPortBlockWithName(obj.SSBlockHandle,cacheStruct(1,i).Name);
                        assert(~isempty(newPortHdl));
                        newPortSID=get_param(newPortHdl,'SID');
                        numHdls=numel(newPortHdl);
                        if numHdls==1
                            oldPortSID={oldPortSID};
                            newPortSID={newPortSID};
                        end
                        for j=1:numHdls
                            bridgeData.updateBridgeDataMap(oldPortSID{j},newPortSID{j},newPortHdl(j));
                        end
                    end
                end
            end

            updateMappingForCacheStructure(obj.archCache.inputPortInfo);
            updateMappingForCacheStructure(obj.archCache.outputPortInfo);
            updateMappingForCacheStructure(obj.archCache.physicalPortInfo);

            slreq.utils.onHierarchyChange('postchange',obj.SSBlockHandle);




            inportBlocks=find_system(obj.SSBlockHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport');
            if~isempty(inportBlocks)
                set_param(inportBlocks(1),'Position',[100,100,110,110]);
                for idx=2:numel(inportBlocks)
                    pos=get_param(inportBlocks(idx-1),'Position');
                    pos(2)=pos(2)+25;
                    pos(4)=pos(4)+25;
                    set_param(inportBlocks(idx),'Position',pos);
                end
            end
            outportBlocks=find_system(obj.SSBlockHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport');
            if~isempty(outportBlocks)
                set_param(outportBlocks(1),'Position',[500,100,510,110]);
                for idx=2:numel(outportBlocks)
                    pos=get_param(outportBlocks(idx-1),'Position');
                    pos(2)=pos(2)+25;
                    pos(4)=pos(4)+25;
                    set_param(outportBlocks(idx),'Position',pos);
                end
            end
            physicalPortBlocks=find_system(obj.SSBlockHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','PMIOPort');
            if~isempty(physicalPortBlocks)
                set_param(physicalPortBlocks(1),'Position',[600,100,630,114]);
                for idx=2:numel(physicalPortBlocks)
                    pos=get_param(physicalPortBlocks(idx-1),'Position');
                    pos(2)=pos(2)+35;
                    pos(4)=pos(4)+35;
                    set_param(physicalPortBlocks(idx),'Position',pos);
                end
            end
        end

        function enableSimulinkListener(obj)


            delete(obj.archPluginTxn);
        end

        function postEnableSimulinkListener(obj)

            query=Simulink.FindOptions('SearchDepth',1);
            obj.prthdls=[Simulink.findBlocksOfType(obj.SSBlockHandle,'Inport',query);Simulink.findBlocksOfType(obj.SSBlockHandle,'Outport',query)];


            set_param(obj.SSBlockHandle,'PortSchema',obj.portPlacementSchema);


            comp=systemcomposer.utils.getArchitecturePeer(obj.SSBlockHandle);
            obj.archCache.recreateConnectionsBetweenCachedPorts(comp);


            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);
        end

        function foundHandle=findPortBlockWithName(~,parentBlock,portName)
            function match=matchPortWithName(handle)
                match=false;
                if strcmp(get_param(handle,'Type'),'block')
                    blockType=get_param(handle,'BlockType');
                    if strcmp(blockType,'Inport')||...
                        strcmp(blockType,'Outport')
                        if(strcmpi(get_param(handle,'isComposite'),'on'))
                            match=strcmp(get_param(handle,'PortName'),portName);
                        else
                            match=strcmp(get_param(handle,'Name'),portName);
                        end
                    elseif strcmp(blockType,'PMIOPort')
                        match=strcmp(get_param(handle,'Name'),portName);
                    end
                end
            end
            foundHandle=find_system(parentBlock,'MatchFilter',@matchPortWithName);
        end

    end
end
