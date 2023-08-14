classdef ChartImplToComponentConverter<handle








    properties(Access=protected)
        BlockHandle;
        BDHandle;
        ValidationPassed;
        CompBlockHandle;
        portPlacementSchema;
        subPorts;
        prthdls;
    end

    properties(Access=private)
        archPluginTxn;
        archCache;
    end

    methods(Access=public)
        function obj=ChartImplToComponentConverter(blkH)

            assert(ishandle(blkH));


            obj.BlockHandle=blkH;


            obj.BDHandle=get_param(bdroot(blkH),'Handle');


            obj.CompBlockHandle=[];
        end
    end

    methods(Sealed,Access=public)
        function CompBlockHandle=convertChartImplToComponent(obj)
            CompBlockHandle=[];%#ok<NASGU>
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


                CompBlockHandle=obj.replaceBlock();
                obj.CompBlockHandle=CompBlockHandle;


                obj.postReplaceBlock();


                obj.enableSimulinkListener();


                obj.postEnableSimulinkListener();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);


                prunerDisabler.delete();

            catch ME

                CompBlockHandle=[];%#ok<NASGU>


                prunerDisabler.delete();

                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=private)
        function runValidationChecks(obj)

            assert(systemcomposer.internal.isStateflowBehaviorComponent(obj.BlockHandle));
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
            comp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            curArch=comp.getArchitecture;
            zcModel=mf.zero.getModel(comp);
            txn=zcModel.beginTransaction;




            obj.subPorts=curArch.getPortsAcrossHierarchy;
            for idx=1:numel(obj.subPorts)
                curArch.removePort(obj.subPorts(idx));
            end
            txn.commit;
        end


        function CompBlockHandle=replaceBlock(obj)


            srcBlkFullName=getfullname(obj.BlockHandle);
            srcBlkName=get_param(obj.BlockHandle,'Name');



            comp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            zcModel=mf.zero.getModel(comp);






            txn=zcModel.beginTransaction;


            newArch=systemcomposer.architecture.model.design.Architecture.createArchitecture(zcModel,srcBlkName);

            srcArch.modelName=get_param(obj.BDHandle,'Name');
            srcArch.UUID=comp.getArchitecture.UUID;
            dstArch.modelName=get_param(obj.BDHandle,'Name');
            dstArch.UUID=newArch.UUID;

            systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes(srcArch,dstArch);

            slreq.utils.onHierarchyChange('prechange',obj.BlockHandle);


            ssBlk=slInternal('replace_block',srcBlkFullName,'built-in/Subsystem','KeepSID','on');
            CompBlockHandle=get_param(ssBlk,'Handle');
            SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(CompBlockHandle,SimulinkSubDomainMI.SimulinkSubDomainEnum.Architecture);


            comp.setSubArchitecture(newArch);

            slreq.utils.onHierarchyChange('postchange',CompBlockHandle);



            for idx=1:numel(obj.subPorts)
                newArch.addPort(obj.subPorts(idx));
            end
            txn.commit;
        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.CompBlockHandle)&&ishandle(obj.CompBlockHandle));
            comp=systemcomposer.utils.getArchitecturePeer(obj.CompBlockHandle);

            obj.archCache.restoreComponentSIDBridgeMapping(obj.CompBlockHandle);

            bridgeData=obj.archCache.bridgeData;




            for portType={'/Bus Element In1','/Bus Element Out1'}
                portType=char(portType);%#ok<FXSET>
                portInfo='inputPortInfo';
                blockPath='simulink/Ports & Subsystems/In Bus Element';
                if strcmp(portType,'/Bus Element Out1')
                    portInfo='outputPortInfo';
                    blockPath='simulink/Ports & Subsystems/Out Bus Element';
                end
                if~isempty(obj.archCache.(portInfo))
                    [~,idx]=sort([obj.archCache.(portInfo).PortNum]);
                    for i=1:1:numel(obj.archCache.(portInfo))
                        fullPortName=[comp.getQualifiedName,portType];

                        bh=add_block(blockPath,fullPortName,'MakeNameUnique','on','CreateNewPort','on','PortName',obj.archCache.(portInfo)(1,idx(i)).Name,'Element','');
                        oldPortSID=string(obj.archCache.(portInfo)(1,idx(i)).PortSID);
                        newPortSID=get_param(bh,'SID');
                        bridgeData.updateBridgeDataMap(oldPortSID,newPortSID,bh);
                    end
                end
            end



























        end

        function enableSimulinkListener(obj)


            delete(obj.archPluginTxn);
        end

        function postEnableSimulinkListener(obj)

            query=Simulink.FindOptions('SearchDepth',1);
            obj.prthdls=[Simulink.findBlocksOfType(obj.CompBlockHandle,'Inport',query);Simulink.findBlocksOfType(obj.CompBlockHandle,'Outport',query)];


            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);


            set_param(obj.CompBlockHandle,'PortSchema',obj.portPlacementSchema);


            comp=systemcomposer.utils.getArchitecturePeer(obj.CompBlockHandle);
            obj.archCache.recreateConnectionsBetweenCachedPorts(comp);
        end
    end
end
