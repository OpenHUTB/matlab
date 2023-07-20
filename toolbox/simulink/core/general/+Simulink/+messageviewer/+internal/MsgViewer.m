



classdef MsgViewer<handle

    properties(Hidden)
        m_MsgTabs;

        m_Dialog;
        m_ModelName;
        m_ComponentId;
        m_ModelLoadRecord;
        m_RefComponentList;

        m_GroupSimilarWarnings;
        m_MessageSequence;
        m_MessageService;
        m_isClientAlive;

        m_StageSequence;
    end


    methods(Access='public')

        function show(this)
            if~isempty(this)&&~isempty(this.m_Dialog)
                this.m_Dialog.show();
            end
        end

        function close(this)
            if~isempty(this)&&~isempty(this.m_Dialog)
                this.hide();
            end
        end

        function hide(this)
            this.m_MsgTabs={};
            if~isempty(this)&&~isempty(this.m_Dialog)
                this.m_Dialog.hide();
            end
        end

        function[bIsVisible]=isVisible(this)
            if~isempty(this)&&~isempty(this.m_Dialog)
                bIsVisible=this.m_Dialog.isVisible();
            end
        end

        function toggleDock(this)
            if~isempty(this)&&~isempty(this.m_Dialog)
                this.m_Dialog.toggleDock();
            end
        end

    end


    methods(Access='public',Hidden=true)

        function obj=MsgViewer(aModelName,aComponentId)
            connector.ensureServiceOn();

            if nargin>1
                obj.m_ComponentId=aComponentId;
            else
                obj.m_ComponentId=slmsgviewer.m_DefaultComponentId;
            end

            obj.m_MsgTabs={};
            obj.m_ModelLoadRecord=[];
            obj.m_ModelName=aModelName;
            obj.m_GroupSimilarWarnings=true;
            obj.m_MessageSequence=Simulink.messageviewer.internal.MsgIdGenerator;
            obj.m_MessageService=Simulink.messageviewer.internal.MessageService(obj.m_ComponentId);
            obj.m_MessageService.subscribe('js2matlab',@(data)jsToMatlabEventHandler(obj,data));
            obj.m_isClientAlive=false;
            obj.m_RefComponentList=string.empty;
            obj.m_StageSequence=0;

            if(strcmp(aModelName,slmsgviewer.m_DefaultModelName))
                obj.m_Dialog=Simulink.messageviewer.internal.BrowserDialogFactory.create('CEF');
                obj.m_isClientAlive=obj.m_Dialog.isAlive();

            else
                obj.m_Dialog=Simulink.messageviewer.internal.BrowserDialogFactory.create('DOCK',aComponentId);
            end
        end

        function reset(this)
            this.m_MessageService.unsubscribe('js2matlab');
        end

        function delete(this)
            this.reset();
            if~isempty(this.m_Dialog)
                this.m_Dialog.delete();
            end
            this.m_MessageService.delete();
        end

        function iStageSequence=getStageSequence(this)
            this.m_StageSequence=this.m_StageSequence+1;
            iStageSequence=this.m_StageSequence;
        end

        function processRecordDV(this,aRecord)
            if(slmsgviewer.IsStageRecord(aRecord))
                if slmsgviewer.isModelLoadEndStage(aRecord)
                    if~isempty(this.m_ModelLoadRecord)
                        this.m_ModelLoadRecord=[];
                        return;
                    end
                end

                if slmsgviewer.isModelLoadStartStage(aRecord)
                    this.m_ModelLoadRecord=aRecord;
                    return;
                end

                this.processStageRecord(aRecord);
            else
                if~isempty(this.m_ModelLoadRecord)
                    this.processStageRecord(this.m_ModelLoadRecord);
                    this.m_ModelLoadRecord=[];
                end

                this.pushMessageRecord(aRecord);
            end
        end

        function remove(this,aTabName)


            this.m_MessageService.publish('removeTab',aTabName);
            this.notifyCloseTab(aTabName);
        end

        function rename(this,aOldTabName,aNewTabName)
            if~strcmp(this.m_ModelName,'_ALL_')
                this.m_ModelName=aNewTabName;
            end

            aRenameStruct.aOldTabName=aOldTabName;
            aRenameStruct.aNewTabName=aNewTabName;
            this.m_MessageService.publish('renameTab',aRenameStruct);

            aTabInfo=this.getTabInfo(aOldTabName);
            if~isempty(aTabInfo)
                aTabInfo.m_TabName=aNewTabName;
            end
        end


        function reposition(this,aCenterXPos,aCenterYPos)
            this.m_Dialog.reposition(aCenterXPos,aCenterYPos);
        end

        function[aMsgRecords]=getRecordsDV(this,aModelName)
            aMsgRecords=[];
            this.m_MessageService.subscribe('getRecords',@recordReceiver);
            bIsReady=false;

            this.m_MessageService.publish('requestRecords',aModelName);

            iCounter=0;
            while(~bIsReady&&iCounter<120)
                pause(1);
                iCounter=iCounter+1;
            end

            this.m_MessageService.unsubscribe('getRecords');

            function recordReceiver(aRecords)
                aMsgRecords=aRecords;
                bIsReady=true;
            end
        end

        function settingsDV(this,aSettingName,iSettingValue)
            aSettings.aSettingName=aSettingName;
            aSettings.iSettingValue=iSettingValue;
            this.m_MessageService.publish('settings',aSettings);
        end

        function updateRefHyperlinkCB(this,aComponentName,aCB)
            aCBObj=struct;
            aCBObj.Name=aComponentName;
            aCBObj.CB=aCB;
            this.m_MessageService.publish('refHyperlinkCB',jsonencode(aCBObj));
        end

        function addToRefComponentList(this,aList)

            this.m_RefComponentList=[this.m_RefComponentList,aList];
            this.m_RefComponentList=unique(this.m_RefComponentList);

            this.m_MessageService.publish('modelreflist',this.m_RefComponentList);
        end

        function removeFromRefComponentList(this,aList)

            for i=1:length(aList)
                this.m_RefComponentList=this.m_RefComponentList(this.m_RefComponentList~=aList(i));
            end

            this.m_MessageService.publish('modelreflist',this.m_RefComponentList);
        end

        function bCanProcess=canProcess(this,aModelName)
            bCanProcess=false;

            if~slmsgviewer.IsDockable
                return;
            end

            if(strcmp(aModelName,slmsgviewer.m_DefaultModelName))
                bCanProcess=true;
            else

                if strcmp(this.m_ModelName,aModelName)
                    bCanProcess=true;
                end


                for i=1:length(this.m_RefComponentList)
                    if strcmp(this.m_RefComponentList(i),aModelName)
                        bCanProcess=true;
                    end
                end
            end
        end
    end


    methods(Access='protected')

        function[aTabInfo]=getTabInfo(this,aTabNameOrId)

            if~strcmp(this.m_ComponentId,'0')
                aTabNameOrId=this.m_ModelName;
            end

            for i=1:length(this.m_MsgTabs)
                aTabInfo=this.m_MsgTabs{i};
                if((strcmp(aTabInfo.m_TabName,aTabNameOrId))||(strcmp(aTabInfo.getId(),aTabNameOrId)))
                    return;
                end
            end

            aTabInfo=[];
        end

        function[aTabInfo]=addTabInfo(this,aTabName)

            if~strcmp(this.m_ComponentId,'0')
                aTabName=this.m_ModelName;
            end

            aTabInfo=Simulink.messageviewer.internal.MsgTabInfo(aTabName,this);
            this.m_MsgTabs{end+1}=aTabInfo;

            if 1==length(this.m_MsgTabs)
                this.position(aTabName);
            end
        end

        function bCleared=clearTabInfo(this,aTabName)
            for i=1:length(this.m_MsgTabs)
                if strcmp(this.m_MsgTabs{i}.m_TabName,aTabName)
                    this.m_MsgTabs(i)=[];
                    bCleared=true;
                    return;
                end
            end

            bCleared=false;
        end

        function clear(this,aTabId,iStageId,bIsLatestStage)
            aTabInfo=this.getTabInfo(aTabId);
            if~isempty(aTabInfo)
                aTabInfo.clearStage(iStageId);

                if bIsLatestStage
                    aTabInfo.updateStatusBar('');
                end
            end
        end

        function[bIsOkayToHide]=isOkayToHide(this)
            bIsOkayToHide=isempty(this.m_MsgTabs);
        end

        function processStageStartRecord(this,aRecord)
            if~this.m_isClientAlive
                this.m_isClientAlive=this.m_Dialog.isAlive();

            end

            aTabInfo=this.getTabInfo(aRecord.ModelName);
            if isempty(aTabInfo)
                aTabInfo=this.addTabInfo(aRecord.ModelName);
            end

            aTabInfo.incrementStageDepth();
            aRecord.TabId=aTabInfo.getId();
            aRecord.StageNumber=aTabInfo.getCurrentStageId();
            this.m_MessageService.publish('pushStage',aRecord);
        end

        function processStageEndRecord(this,aRecord)
            aTabInfo=this.getTabInfo(aRecord.ModelName);


            this.pushCount(aTabInfo);








            this.m_MessageService.publish('pushStage',aRecord);

            if~isempty(aTabInfo)
                aTabInfo.decrementStageDepth();
            end
        end

        function processStageRecord(this,aRecord)
            if isequal(aRecord.StageState,1)
                this.processStageStartRecord(aRecord);
            else
                this.processStageEndRecord(aRecord);
            end
        end



        function aMsgJSONStr=getMsgNodes(this,aTabName,iStageId,aMsgId)
            aMsgJSONStr=[];
            aMsgNodes=[];

            aTabInfo=this.getTabInfo(aTabName);
            if~isempty(aTabInfo)
                if isempty(aMsgId)
                    aKeySet=aTabInfo.getKeysGivenStageId(iStageId);
                else
                    aKeySet={aMsgId};
                end

                for i=1:length(aKeySet)
                    aTempNodes=aTabInfo.getRecordsGivenMsgId(iStageId,aKeySet{i});
                    if~isempty(aTempNodes)
                        aTempNodes(1)=[];
                        aMsgNodes=[aMsgNodes,aTempNodes];%#ok<AGROW>
                        aTabInfo.clearOnlyGivenMsgId(iStageId,aKeySet{i});
                    end
                end
            end


            if~isempty(aMsgNodes)
                aMsgJSONStr=jsonencode(aMsgNodes);
            end
        end


        function setShowUniqueFlag(this,bGroupSimilarWarnings)
            this.m_GroupSimilarWarnings=bGroupSimilarWarnings;
        end

        function pushMessageRecord(this,aRecord)
            if~this.m_isClientAlive
                this.m_isClientAlive=this.m_Dialog.isAlive();

            end


            aTabInfo=this.getTabInfo(aRecord.ModelName);
            if isempty(aTabInfo)&&~isempty(aRecord.ModelName)
                aTabInfo=this.addTabInfo(aRecord.ModelName);
            end

            if(~isempty(aTabInfo))
                aRecord.TabId=aTabInfo.getId();
            end


            if(aRecord.Severity==slmsgviewer.m_InfoSeverity)
                this.m_MessageSequence.IncrementInfoSequenceNo();
                aRecord.SequenceNo=this.m_MessageSequence.GetSequenceNo();
            else
                this.m_MessageSequence.IncrementMessageSequenceNo();
                aRecord.SequenceNo=this.m_MessageSequence.GetSequenceNo();
            end

            if(this.m_GroupSimilarWarnings)&&(aRecord.Severity==slmsgviewer.m_WarnSeverity||aRecord.Severity==slmsgviewer.m_HighPriorityWarning)
                iNumSimilarRecordCount=aTabInfo.pushMsgInMap(aRecord.MessageId,aRecord);
                if(iNumSimilarRecordCount==1)
                    this.m_MessageService.publish('pushMsg',aRecord);
                end
            else
                this.m_MessageService.publish('pushMsg',aRecord);
            end


            if(mod(aRecord.SequenceNo,100)==0)
                this.pushCount(aTabInfo);
            end

            if length(this.m_MsgTabs)>slmsgviewer.m_DefaultMaxMsgTabs

                drawnow;
            end

            if isempty(aTabInfo)
                this.show();
            else
                aTabInfo.incrementRecordCount(aRecord.Severity);
                if(isequal(aRecord.Severity,slmsgviewer.m_ErrorSeverity)||isequal(aRecord.Severity,slmsgviewer.m_HighPriorityWarning))
                    this.show();
                end
            end
        end

        function pushCount(this,aTabInfo)
            if~isempty(aTabInfo)&&this.m_GroupSimilarWarnings
                aKeySet=aTabInfo.getKeysInMap();
                if~isempty(aKeySet)
                    aCountStruct=struct;
                    for i=1:length(aKeySet)
                        aCountStruct(i).MessageId=aKeySet{i};
                        aCountStruct(i).ModelName=aTabInfo.m_TabName;
                        aCountStruct(i).aCount=aTabInfo.getCountGivenMsgId(aKeySet{i});
                    end
                    this.m_MessageService.publish('pushCount',aCountStruct);
                end
            end
        end

        function removeModelTab(this,aTabName)

            this.m_MessageService.publish('removeModelTabDV',aTabName);
            this.notifyCloseTab(aTabName);
        end

        function notifyCloseTab(this,aTabName)
            slmsgviewer.notifyEvent('PushUIEvent',struct('Event','closeEvent','ModelName',aTabName));

            if(this.clearTabInfo(aTabName))
                open_and_hilite_hyperlink(aTabName,'none');
                slprivate('open_and_hilite_port_hyperlink','clear',aTabName)
                if(this.isOkayToHide())
                    this.hide();
                end
            end
        end

        function[bIsPresent]=isPresent(this,aTabName)
            bIsPresent=~isempty(this.getTabInfo(aTabName));
        end


        function position(this,aModelName)
            this.m_Dialog.position(aModelName);
        end


        function[aMsgNodes]=sendMsgToJs(this,aTabName,iStageId,aMsgId)
            aMsgNodes=this.getMsgNodes(aTabName,iStageId,aMsgId);
        end

        function bringupDockedDV(this)
            this.show();
        end

        function jsToMatlabEventHandler(this,aData)
            switch(aData{1})
            case 'Clear'
                this.clear(aData{2},aData{3},aData{4});
            case 'RemoveModelTab'
                this.removeModelTab(aData{2});
            case 'FileChooser'
                aDataObj=struct();
                aDataObj.sessionId=aData{3};
                aDataObj.argsOut=slmsgviewer.showFileChooser(aData{2});
                this.m_MessageService.publish('matlab2js',aDataObj);
            case 'ModelName'
                aDataObj=struct();
                aDataObj.sessionId=aData{2};
                aDataObj.argsOut=this.m_ModelName;
                this.m_MessageService.publish('matlab2js',aDataObj);
            case 'SetShowUnique'
                this.setShowUniqueFlag(aData{2});
            case 'DockUndock'
                this.toggleDock();
            case 'Close'
                this.hide();
            case 'Open'
                slmsgviewer.show(this.m_ModelName);
            case 'SendMessageToJs'
                aDataObj=struct();
                aDataObj.sessionId=aData{5};
                aDataObj.argsOut=[];
                payload=this.sendMsgToJs(aData{2},aData{3},aData{4});
                broadcast_data=struct('modelName',aData{2},'stageId',aData{3},'data',payload);

                this.m_MessageService.publish('backendBroadcast',broadcast_data);

                this.m_MessageService.publish('matlab2js',aDataObj);
            end
        end
    end
end


