




classdef(Hidden=true)BusHierarchyDialogMgr<handle

    methods(Static)

        function url=openDialog(portHndl,modelHandle,x,y)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;


            if~isKey(channelMap,modelHandle)

                modelHandleStr=num2str(modelHandle,'%.15f');
                channelPrefix=['/SigHierDisplay/',modelHandleStr];
                connector.ensureServiceOn;


                loadChannel=[channelPrefix,'/load'];
                fhl=@(x)Simulink.internal.BusHierarchyDialogMgr.loadHandler(x,modelHandle);
                value.loadSub=message.subscribe(loadChannel,fhl);
                value.testDialogStatus=false;



                highlightChannel=[channelPrefix,'/highlight'];
                fht=@(x)Simulink.internal.BusHierarchyDialogMgr.highlightHandler(x,modelHandle);
                value.highlightSub=message.subscribe(highlightChannel,fht);



                lockedViewerChannel=[channelPrefix,'/lockedViewer'];
                fhc=@(x)Simulink.internal.BusHierarchyDialogMgr.lockedViewerHandler(x,modelHandle);
                value.lockedSub=message.subscribe(lockedViewerChannel,fhc);


                testPostPopulateChannel=[channelPrefix,'/testPostPopulate'];
                fhp=@(x)Simulink.internal.BusHierarchyDialogMgr.testPostPopulateHandler(x,modelHandle);
                value.testDialogStatusSub=message.subscribe(testPostPopulateChannel,fhp);


                value.sigInfoChannel=[channelPrefix,'/signalInfo'];


                value.compiledAttributesChannel=[channelPrefix,'/compiledAttributes'];


                value.chgSigChannel=[channelPrefix,'/chgSig'];
                channelMap(modelHandle)=value;

                Simulink.addBlockDiagramCallback(modelHandle,'PreClose',...
                'BusHierarchyDialog',@()Simulink.internal.BusHierarchyDialogMgr.remove(modelHandle));
            else
                value=channelMap(modelHandle);
            end

            value.dialog=Simulink.internal.BusHierarchyDialog(portHndl,modelHandle,x,y);
            url=value.dialog.URL;
            channelMap(modelHandle)=value;
        end

        function loadHandler(portHdl,modelHandle)
            if(ischar(portHdl))
                portHandle=str2double(portHdl);
            else
                portHandle=portHdl;
            end
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            channelName=channelMap(modelHandle).sigInfoChannel;
            shData=get_param(portHandle,'SignalHierarchy');
            parentBlk=get_param(portHandle,'Parent');
            C=strsplit(parentBlk,'/');
            blockName=C{end};
            blockName=strrep(blockName,' ','');
            portName=get_param(portHandle,'Name');
            portNumber=num2str(get_param(portHandle,'PortNumber'));

            if isempty(portName)
                signalName=blockName;
            else
                signalName=[portName,' (',blockName,') : ',portNumber];
            end
            shData.SignalName=strrep(signalName,newline,' ');
            msg.sigHierarchy=shData;
            message.publish(channelName,msg);
        end



        function highlightHandler(signalArray,modelHandle)

        end

        function lockedViewerHandler(changeVal,modelHandle)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            value=channelMap(modelHandle);
            value.dialog.unlocked=changeVal;
        end

        function compileCallBack(modelHandle,portHandle)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            channelName=channelMap(modelHandle).compiledAttributesChannel;
            y=Simulink.internal.BusHierarchyDialogMgr.getSignalDescriptorFromPortHandle(portHandle);
            message.publish(channelName,y);
        end

        function testPostPopulateHandler(~,modelHandle)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            k=channelMap(modelHandle);
            k.testDialogStatus=true;
            channelMap(modelHandle)=k;
        end

        function changeSignal(modelHandle,portHandle)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            channelName=channelMap(modelHandle).chgSigChannel;
            message.publish(channelName,portHandle);
        end

        function d=getSignalDescriptorFromPortHandle(ph)
            d=[];
            po=get_param(ph,'Object');
            if~isa(po,'Simulink.Port')||~po.isHierarchySimulating
                return;
            end
            cbs=po.CompiledBusStruct;
            if isempty(cbs)
                d=Simulink.internal.BusHierarchyDialogMgr.fillLeafAttributes(po,cbs,d);
            else
                d=Simulink.internal.BusHierarchyDialogMgr.fillBusAttributes(po,cbs,d);
            end
        end

        function d=fillLeafAttributes(po,cbs,d)
            if~isempty(cbs)
                sph=get_param(cbs.src,'PortHandles');
                po=get_param(sph.Outport(cbs.srcPort+1),'Object');
                d.SignalName=cbs.name;
                d.Label=po.Label;
                if~isempty(cbs.parentBusObjectName)
                    model=bdroot(get_param(cbs.src,'Parent'));
                    busDetails=slInternal('busDiagnostics','getDFSElementsInBus',model,cbs.parentBusObjectName,1);
                    record=[];
                    for idx=1:length(busDetails)
                        if isequal(busDetails(idx).flatIndex,cbs.flatDataTypeElemIdx)
                            record=busDetails(idx);
                            break;
                        end
                    end
                    assert(~isempty(record));

                    busType='NOT_BUS';
                    if~isempty(cbs.signals)
                        sph=get_param(cbs.src,'PortHandles');
                        po=get_param(sph.Outport(cbs.srcPort+1),'Object');
                        busType=po.CompiledBusType;
                    end

                    if(isempty(d.SignalName))
                        d.SignalName=record.eName;
                    end
                    d.CompiledBusType=busType;
                    d.CompiledPortDataType=record.dataType;
                    d.CompiledPortDimensions=record.dimensions;
                    d.CompiledPortWidth=record.width;
                    d.CompiledPortComplexSignal=strcmpi(record.signalType,'complex');
                    d.CompiledPortDimensionsMode=~strcmpi(record.dimensionsMode,'fixed');
                    d.CompiledPortFrameData=~strcmpi(record.samplingMode,'sample-based');
                    d.CompiledPortDesignMin=record.min;
                    if isinf(d.CompiledPortDesignMin)
                        d.CompiledPortDesignMin=[];
                    end
                    d.CompiledPortDesignMax=record.max;
                    if isinf(d.CompiledPortDesignMax)
                        d.CompiledPortDesignMax=[];
                    end
                    d.Signals={};
                    return;
                end
            else
                assert(~isempty(po));
            end
            d.Label=po.Label;
            d.CompiledBusType=po.CompiledBusType;
            d.CompiledPortDataType=po.CompiledPortDataType;
            d.CompiledPortDimensions=po.CompiledPortDimensions;
            d.CompiledPortWidth=po.CompiledPortWidth;
            d.CompiledPortComplexSignal=po.CompiledPortComplexSignal;
            if isequal(d.CompiledPortComplexSignal,-1)
                d.CompiledPortComplexSignal=false;
            end
            d.CompiledPortDimensionsMode=po.CompiledPortDimensionsMode;
            d.CompiledPortFrameData=po.CompiledPortFrameData;
            try
                d.CompiledPortDesignMin=po.CompiledPortDesignMin;
                d.CompiledPortDesignMax=po.CompiledPortDesignMax;
            catch
                d.CompiledPortDesignMin=[];
                d.CompiledPortDesignMax=[];
            end
            d.Signals={};
        end

        function d=fillBusAttributes(po,cbs,d)
            if isempty(po)
                assert(~isempty(cbs)&&~isempty(cbs.src)&&~isempty(cbs.srcPort));
                sph=get_param(cbs.src,'PortHandles');
                po=get_param(sph.Outport(cbs.srcPort+1),'Object');
            end

            d=Simulink.internal.BusHierarchyDialogMgr.fillLeafAttributes(po,cbs,d);
            if~strcmpi(d.CompiledBusType,'NOT_BUS')
                d.Signals=cell(length(cbs.signals),1);
                for idx=1:length(cbs.signals)
                    if isempty(cbs.signals(idx).signals)
                        d.Signals{idx}=Simulink.internal.BusHierarchyDialogMgr.fillLeafAttributes([],cbs.signals(idx),[]);
                    else
                        d.Signals{idx}=Simulink.internal.BusHierarchyDialogMgr.fillBusAttributes([],cbs.signals(idx),[]);
                    end
                end
            end
        end
    end

    methods
        function delete(~)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            channelKeys=keys(channelMap);
            for i=1:length(channelKeys)
                value=channelMap(channelKeys{i});
                message.unsubscribe(value.loadSub);
                message.unsubscribe(value.highlightSub);
                message.unsubscribe(value.lockedSub);
                remove(channelMap,channelKeys{i});
            end
        end
    end

    methods(Static,Hidden)

        function ret=getPersistentHashMap(~)
            persistent hashMap;
            mlock;
            if isempty(hashMap)||~isvalid(hashMap)
                hashMap=containers.Map('KeyType','double','ValueType','any');
            end

            ret=hashMap;
        end

        function remove(modelHandle)
            channelMap=Simulink.internal.BusHierarchyDialogMgr.getPersistentHashMap;
            if isKey(channelMap,modelHandle)
                value=channelMap(modelHandle);
                message.unsubscribe(value.loadSub);
                message.unsubscribe(value.highlightSub);
                message.unsubscribe(value.lockedSub);
                delete(value.dialog);
                remove(channelMap,modelHandle);
            end
        end
    end
end

