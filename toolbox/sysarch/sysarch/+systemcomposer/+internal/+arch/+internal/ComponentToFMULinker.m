classdef ComponentToFMULinker<systemcomposer.internal.arch.internal.ComponentToModelLinker









    properties(Access=protected)
        FMUBlockHandle;
        FMUImplementation;
    end

    methods(Access=public)
        function obj=ComponentToFMULinker(blkH,fmuFile,impl)
            assert(ishandle(blkH));

            obj@systemcomposer.internal.arch.internal.ComponentToModelLinker(blkH,fmuFile);
            obj.FMUBlockHandle=[];
            if nargin>=3
                obj.FMUImplementation=impl;
            else
                obj.FMUImplementation='';
            end
        end
    end

    methods(Sealed,Access=public)
        function sysBlkH=linkComponentToFMU(obj)

            blkH=obj.OldBlockHandle;
            bdH=bdroot(blkH);

            try

                obj.preDisableSimulinkListener();


                obj.disableSimulinkListener();


                obj.cacheConnectionsBeforeDelete();


                obj.deleteConnectedLines();


                obj.preReplaceBlock();


                sysBlkH=obj.replaceBlock();


                obj.postReplaceBlock();


                obj.enableSimulinkListener();


                obj.postEnableSimulinkListener();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdH);
            catch ME
                rethrow(ME);
            end
        end

        function sysBlkH=linkComponentToModel(~)
            error('Invoke linkComponentToFMU method instead.');
            sysBlkH=[];
        end
    end

    methods(Sealed,Access=protected)

        function sysBlkH=replaceBlock(obj)

            import systemcomposer.internal.arch.internal.ZCUtils;
            try
                blkFullName=getfullname(obj.OldBlockHandle);
                bdH=get_param(bdroot(obj.OldBlockHandle),'Handle');

                blockParams=ZCUtils.getBlockParams(obj.OldBlockHandle);

                slreq.utils.onHierarchyChange('prechange',bdH);




                sysBlk=slInternal('replace_block',blkFullName,'built-in/Subsystem','KeepSID','on');
                sysBlkH=get_param(sysBlk,'Handle');

                obj.NewBlockHandle=sysBlkH;

                fmuBlkH=add_block('simulink_extras/FMU Import/FMU',[blkFullName,'/FMU Block']);
                if strcmp(obj.FMUImplementation,'')



                    s=warning('off','FMUBlock:FMU:FMUModeNotSupportedAndSet');
                    sOC=onCleanup(@()warning(s.state,s.identifier));

                    set_param(fmuBlkH,'FMUName',obj.LinkTargetFile,'FMUMode','CoSimulation');
                    sOC.delete;
                else
                    set_param(fmuBlkH,'FMUName',obj.LinkTargetFile,'FMUMode',obj.FMUImplementation);
                end
                obj.FMUBlockHandle=fmuBlkH;

                systemcomposer.internal.arch.internal.ComponentToFMULinker.updateComponentInterfaceSL(fmuBlkH);

                slreq.utils.onHierarchyChange('postchange',bdH);
                ZCUtils.restoreBlockParams(obj.NewBlockHandle,blockParams);

            catch ME
                rethrow(ME);
            end
        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.NewBlockHandle)&&ishandle(obj.NewBlockHandle));
            sysBlkH=obj.NewBlockHandle;

            obj.archCache.restoreComponentSIDBridgeMapping(sysBlkH);
            obj.archCache.removeCachedPortsFromBridgeMap;


            comp=systemcomposer.utils.getArchitecturePeer(sysBlkH);
            mfMdl=mf.zero.getModel(comp);
            txn=mfMdl.beginTransaction;


            subArch=systemcomposer.internal.arch.internal.ComponentToFMULinker.createZCArchitecture(obj.FMUBlockHandle,mfMdl);

            comp.setSubArchitecture(subArch);


            bdH=bdroot(obj.FMUBlockHandle);
            bridgeData=get_param(bdH,'SimulinkArchBridgeData');
            bridgeDataModel=mf.zero.getModel(bridgeData);
            bridgeTxn=bridgeDataModel.beginTransaction;

            f=Simulink.FindOptions('SearchDepth',1);
            portBlockHandles=[...
            Simulink.findBlocksOfType(sysBlkH,'Inport',f);...
            Simulink.findBlocksOfType(sysBlkH,'Outport',f)];

            for idx=1:numel(portBlockHandles)
                portBlockSID=get_param(portBlockHandles(idx),'SID');
                portBlockName=get_param(portBlockHandles(idx),'PortName');

                archPort=comp.getArchitecture.getPort(portBlockName);
                shouldSerializePortElemPair=true;

                bridgeData.addBlockHandleSIDPair(portBlockHandles(idx),portBlockSID);
                bridgeData.addSimulinkArchitectureElemPair(portBlockSID,archPort.UUID,shouldSerializePortElemPair);
            end
            bridgeTxn.commit;

            txn.commit;
        end
    end

    methods(Static,Access=private)
        function updateComponentInterfaceSL(fmuBlkH)

            sysBlkH=get_param(get_param(fmuBlkH,'Parent'),'Handle');
            blkFullName=getfullname(sysBlkH);

            assert(strcmp(get_param(sysBlkH,'SimulinkSubDomain'),'Simulink'));


            rootInDesc=get_param(fmuBlkH,'FMURootInputDescription');
            rootOutDesc=get_param(fmuBlkH,'FMURootOutputDescription');
            inNames={rootInDesc.Name};
            outNames={rootOutDesc.Name};

            inputPortH=getfield(get_param(fmuBlkH,'PortHandles'),'Inport');
            assert(length(inNames)==length(inputPortH));
            for i=1:length(inNames)

                inBlkH=add_block('simulink/Ports & Subsystems/In Bus Element',...
                [blkFullName,'/Bus Element In1'],...
                'MakeNameUnique','on',...
                'CreateNewPort','on',...
                'PortName',inNames{i},...
                'Element','');

                outputPortH=getfield(get_param(inBlkH,'PortHandles'),'Outport');
                add_line(sysBlkH,outputPortH,inputPortH(i));
            end

            outputPortH=getfield(get_param(fmuBlkH,'PortHandles'),'Outport');
            assert(length(outNames)==length(outputPortH));
            for i=1:length(outNames)

                outBlkH=add_block('simulink/Ports & Subsystems/Out Bus Element',...
                [blkFullName,'/Bus Element Out1'],...
                'MakeNameUnique','on',...
                'CreateNewPort','on',...
                'PortName',outNames{i},...
                'Element','');

                inputPortH=getfield(get_param(outBlkH,'PortHandles'),'Inport');
                add_line(sysBlkH,outputPortH(i),inputPortH);
            end
        end

        function arch=createZCArchitecture(fmuBlkH,mfMdl)




            rootInDesc=get_param(fmuBlkH,'FMURootInputDescription');
            rootOutDesc=get_param(fmuBlkH,'FMURootOutputDescription');
            inNames={rootInDesc.Name};
            outNames={rootOutDesc.Name};

            compName=get_param(fmuBlkH,'Name');
            arch=systemcomposer.architecture.model.sldomain.FMUBlockArchitecture.createFMUBlockArchitecture(mfMdl,compName);

            for i=1:length(inNames)
                arch.addPort(arch.createPort(inNames{i},systemcomposer.internal.arch.REQUEST));
            end
            for i=1:length(outNames)
                arch.addPort(arch.createPort(outNames{i},systemcomposer.internal.arch.PROVIDE));
            end
        end
    end

end



