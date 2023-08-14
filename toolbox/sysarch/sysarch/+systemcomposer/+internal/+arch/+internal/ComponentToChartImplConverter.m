classdef ComponentToChartImplConverter<handle








    properties(Access=protected)
        BlockHandle;
        BDHandle;
        ValidationPassed;
        ChartBlockHandle;
        portPlacementSchema;
        subPorts;
        prthdls;
    end

    properties(Access=private)
        archPluginTxn;
        archCache;
    end

    methods(Access=public)
        function obj=ComponentToChartImplConverter(blkH)

            assert(ishandle(blkH));


            obj.BlockHandle=blkH;


            obj.BDHandle=get_param(bdroot(blkH),'Handle');


            obj.ChartBlockHandle=[];
        end
    end

    methods(Sealed,Access=public)
        function ChartBlockHandle=convertComponentToChartImpl(obj)
            ChartBlockHandle=[];%#ok<NASGU>
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


                ChartBlockHandle=obj.replaceBlock();
                obj.ChartBlockHandle=ChartBlockHandle;


                obj.postReplaceBlock();


                obj.enableSimulinkListener();


                obj.postEnableSimulinkListener();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);


                prunerDisabler.delete();

            catch ME

                ChartBlockHandle=[];%#ok<NASGU>


                prunerDisabler.delete();

                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=private)
        function runValidationChecks(obj)


            if~dig.isProductInstalled('Stateflow')
                obj.ValidationPassed=false;
                msgObj=message('SystemArchitecture:API:StateflowLicenseError');
                exception=MException('systemcomposer:API:StateflowLicenseError',...
                msgObj.getString);
                throw(exception);
            end


            element=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            assert(isa(element,'systemcomposer.architecture.model.design.Component'));
            arch=element.getArchitecture;


            if(element.isReferenceComponent||element.isImplComponent)
                obj.ValidationPassed=false;
                msgObj=message('SystemArchitecture:API:ComponentAlreadyReference');
                exception=MException('systemcomposer:API:ComponentAlreadyReference',...
                msgObj.getString);
                throw(exception);
            end


            if~isempty(arch.getComponents)
                obj.ValidationPassed=false;
                msgObj=message('SystemArchitecture:API:NonEmptyComponentConversionToStateflow');
                exception=MException('systemcomposer:API:NonEmptyComponentConversionToStateflow',...
                msgObj.getString);
                throw(exception);
            end



            ports=arch.getPorts;
            for i=1:numel(ports)
                port=systemcomposer.internal.getWrapperForImpl(ports(i));
                if(port.hasAnonymousCompositeInterface)
                    obj.ValidationPassed=false;
                    msgObj=message('SystemArchitecture:API:StateflowConvOwnedCompInterface');
                    exception=MException('systemcomposer:API:StateflowConvOwnedCompInterface',...
                    msgObj.getString);
                    throw(exception);
                end
            end


            if~isempty(element.getParameterNames)
                msg=message('SystemArchitecture:Parameter:NoParameterSupportInStateflowChart',getfullname(obj.BlockHandle));
                warning('SystemArchitecture:Parameter:NoParameterSupportInStateflowChart',msg.string);
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

            bridgeData=get_param(obj.BDHandle,'SimulinkArchBridgeData');
            curComp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);

            comp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            zcModel=mf.zero.getModel(comp);
            txn=zcModel.beginTransaction;

            if~(curComp.isReferenceComponent||curComp.isImplComponent)


                curArch=curComp.getArchitecture;
                subComps=curArch.getComponentsAcrossHierarchy;
                for idx=1:numel(subComps)
                    curHdl=systemcomposer.utils.getSimulinkPeer(subComps(idx));
                    curSID=get_param(curHdl,'SID');
                    bridgeData.removeBlockHandleSIDPairByHandle(curHdl);
                    bridgeData.removeElemPairForSID(curSID);
                end



                obj.subPorts=curArch.getPortsAcrossHierarchy;
                for idx=1:numel(obj.subPorts)
                    curArch.removePort(obj.subPorts(idx));
                end
            end
            txn.commit;

            slreq.utils.onHierarchyChange('prechange',obj.BlockHandle);
        end


        function ChartBlockHandle=replaceBlock(obj)


            srcBlkFullName=getfullname(obj.BlockHandle);
            srcBlkName=get_param(obj.BlockHandle,'Name');



            comp=systemcomposer.utils.getArchitecturePeer(obj.BlockHandle);
            zcModel=mf.zero.getModel(comp);


            newSFArch=systemcomposer.architecture.model.sldomain.StateflowArchitecture.createStateflowArchitecture(zcModel,srcBlkName);






            txn=zcModel.beginTransaction;

            srcArch.modelName=get_param(obj.BDHandle,'Name');
            srcArch.UUID=comp.getArchitecture.UUID;
            dstArch.modelName=get_param(obj.BDHandle,'Name');
            dstArch.UUID=newSFArch.UUID;

            systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes(srcArch,dstArch);


            chartBlk=slInternal('replace_block',srcBlkFullName,'sflib/Chart','KeepSID','on');
            ChartBlockHandle=get_param(chartBlk,'Handle');


            comp.setSubArchitecture(newSFArch);

            chartId=sfprivate('block2chart',ChartBlockHandle);



            for idx=1:numel(obj.subPorts)
                newSFArch.addPort(obj.subPorts(idx));
            end
            txn.commit;


            stateflowRoot=sfroot;
            chartObj=stateflowRoot.find('-isa','Stateflow.Chart','Id',chartId);




            for portType={'Input','Output'}
                portType=char(portType);%#ok<FXSET>
                portInfo='inputPortInfo';
                if strcmp(portType,'Output')
                    portInfo='outputPortInfo';
                end
                if~isempty(obj.archCache.(portInfo))
                    [~,idx]=sort([obj.archCache.(portInfo).PortNum]);
                    for i=1:1:numel(obj.archCache.(portInfo))
                        sfport(i)=Stateflow.Data(chartObj);%#ok<*AGROW>
                        sfport(i).Name=obj.archCache.(portInfo)(1,idx(i)).Name;
                        archPort=newSFArch.getPort(obj.archCache.(portInfo)(1,idx(i)).Name);
                        if~isempty(archPort.getPortInterfaceName)
                            intrf=systemcomposer.internal.getWrapperForImpl(archPort.getPortInterface);
                            prefix=systemcomposer.BusObjectManager.getPrefixFromInterfaceType(class(intrf));
                            BusObjName=[prefix,archPort.getPortInterfaceName];
                            sfport(i).DataType=BusObjName;
                        end
                        sfport(i).Scope=portType;
                        if~strcmp(obj.archCache.(portInfo)(1,idx(i)).Name,sfport(i).Name)
                            archPort.setName(sfport(i).Name);
                            obj.archCache.(portInfo)(1,idx(i)).Name=sfport(i).Name;
                        end
                    end
                end
            end

        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.ChartBlockHandle)&&ishandle(obj.ChartBlockHandle));
            obj.archCache.restoreComponentSIDBridgeMapping(obj.ChartBlockHandle);

            bridgeData=obj.archCache.bridgeData;


            stateflowRoot=sfroot;
            chartId=sfprivate('block2chart',obj.ChartBlockHandle);
            chartObj=stateflowRoot.find('-isa','Stateflow.Chart','Id',chartId);


            if~isempty(obj.archCache.inputPortInfo)
                for i=1:1:numel(obj.archCache.inputPortInfo)
                    oldPortSID=string(obj.archCache.inputPortInfo(1,i).PortSID);
                    data=chartObj.find('-isa','Stateflow.Data','Name',obj.archCache.inputPortInfo(1,i).Name);
                    prthdl=getSimulinkBlockHandle(Simulink.ID.getFullName(data));
                    newPortSID=get_param(prthdl,'SID');
                    bridgeData.updateBridgeDataMap(oldPortSID,newPortSID,prthdl);
                end
            end
            if~isempty(obj.archCache.outputPortInfo)
                for i=1:1:numel(obj.archCache.outputPortInfo)
                    oldPortSID=string(obj.archCache.outputPortInfo(1,i).PortSID);
                    data=chartObj.find('-isa','Stateflow.Data','Name',obj.archCache.outputPortInfo(1,i).Name);
                    prthdl=getSimulinkBlockHandle(Simulink.ID.getFullName(data));
                    newPortSID=get_param(prthdl,'SID');
                    bridgeData.updateBridgeDataMap(oldPortSID,newPortSID,prthdl);
                end
            end
            slreq.utils.onHierarchyChange('postchange',chartId);
        end

        function enableSimulinkListener(obj)


            delete(obj.archPluginTxn);
        end

        function postEnableSimulinkListener(obj)

            query=Simulink.FindOptions('SearchDepth',1);
            obj.prthdls=[Simulink.findBlocksOfType(obj.ChartBlockHandle,'Inport',query);Simulink.findBlocksOfType(obj.ChartBlockHandle,'Outport',query)];


            set_param(obj.ChartBlockHandle,'PortSchema',obj.portPlacementSchema);


            comp=systemcomposer.utils.getArchitecturePeer(obj.ChartBlockHandle);
            obj.archCache.recreateConnectionsBetweenCachedPorts(comp);


            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.BDHandle);
        end

    end
end
