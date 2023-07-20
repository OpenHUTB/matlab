classdef(Hidden=true)SigHierDialogMgr<handle

    methods(Static)

        function url=openDialog(portHndl,modelHandle,x,y,studioTag,sparkline,debug)
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;

            studio=[];
            if nargin<6
                sparkline=false;
            end

            if sparkline&&~isempty(studioTag)
                studio=DAS.Studio.getStudio(studioTag);
            end

            if~isKey(channelMap,modelHandle)

                modelHandleStr=num2str(modelHandle,'%.15f');
                channelPrefix=['/ValueLabelDisplay/',modelHandleStr];
                connector.ensureServiceOn;
                loadChannel=[channelPrefix,'/load'];
                fhl=@(x)Simulink.internal.SigHierDialogMgr.loadHandler(x,modelHandle,sparkline);
                value.loadSub=message.subscribe(loadChannel,fhl);
                value.testDialogStatus=false;

                selectedSignalsChannel=[channelPrefix,'/selectedSignals'];
                fhs=@(x)Simulink.internal.SigHierDialogMgr.selectedSignalsHandler(x,modelHandle);
                value.selectedSignalsSub=message.subscribe(selectedSignalsChannel,fhs);

                value.sigInfoChannel=[channelPrefix,'/signalInfo'];
                channelMap(modelHandle)=value;

                testPostPopulateChannel=[channelPrefix,'/testPostPopulate'];
                fhp=@(x)Simulink.internal.SigHierDialogMgr.testPostPopulateHandler(x,modelHandle);
                value.testDialogStatusSub=message.subscribe(testPostPopulateChannel,fhp);

                Simulink.addBlockDiagramCallback(modelHandle,'PreClose',...
                'SigHierDialog',@()Simulink.internal.SigHierDialogMgr.remove(modelHandle));
            else
                value=channelMap(modelHandle);
            end

            if nargin<7
                debug=false;
            end
            value.dialog=Simulink.internal.SigHierDialog(portHndl,modelHandle,x,y,studio,sparkline,debug);
            url=value.dialog.URL;
            channelMap(modelHandle)=value;
        end

        function loadHandler(portHdl,modelHandle,sparkline)
            portHandle=str2double(portHdl);
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;
            channelName=channelMap(modelHandle).sigInfoChannel;
            if slfeature('SignalsSparklines')>0&&sparkline
                shData=SLM3I.SLCommonDomain.sparklinesSignalHierarchy(modelHandle,portHandle);
            else
                shData=get_param(portHandle,'SignalHierarchy');
            end
            parentBlk=get_param(portHandle,'Parent');
            C=strsplit(parentBlk,'/');
            blockName=C{end};
            portName=get_param(portHandle,'Name');
            if isempty(portName)
                signalName=blockName;
            else
                signalName=[blockName,'/',portName];
            end
            shData.SignalName=strrep(signalName,sprintf('\n'),' ');
            msg.sigHierarchy=shData;
            if slfeature('SignalsSparklines')>0&&sparkline
                msg.selectedSignals=SLM3I.SLCommonDomain.sparklinesSelectedStreams(modelHandle,portHandle);
            else
                msg.selectedSignals=get_param(portHandle,'BusSignalsForValueLabels');
            end
            message.publish(channelName,msg);
        end

        function selectedSignalsHandler(msg,modelHandle)
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;
            dlg=channelMap(modelHandle).dialog;
            dlg.selectedSignals=msg;
        end

        function testPostPopulateHandler(~,modelHandle)
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;
            k=channelMap(modelHandle);
            k.testDialogStatus=true;
            channelMap(modelHandle)=k;
        end
    end

    methods
        function delete(~)
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;
            channelKeys=keys(channelMap);
            for i=1:length(channelKeys)
                value=channelMap(channelKeys{i});
                message.unsubscribe(value.loadSub);
                message.unsubscribe(value.selectedSignalsSub);
                message.unsubscribe(value.testDialogStatusSub);
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
            channelMap=Simulink.internal.SigHierDialogMgr.getPersistentHashMap;
            if isKey(channelMap,modelHandle)
                value=channelMap(modelHandle);
                message.unsubscribe(value.loadSub);
                message.unsubscribe(value.selectedSignalsSub);
                message.unsubscribe(value.testDialogStatusSub);
                delete(value.dialog);
                remove(channelMap,modelHandle);
            end
        end
    end
end

