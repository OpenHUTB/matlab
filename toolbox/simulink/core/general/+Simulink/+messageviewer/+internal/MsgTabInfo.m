classdef MsgTabInfo<handle

    methods


        function obj=MsgTabInfo(aTabName,aMsgViewer)
            obj.reset();
            obj.setTabName(aTabName);
            obj.m_Id=matlab.lang.internal.uuid;


            obj.m_MsgViewer=aMsgViewer;

            obj.m_StageCounter=0;
            obj.m_StageMap=containers.Map('KeyType','uint64','ValueType','any');
        end

        function delete(this)
            this.updateStatusBar('');
        end

        function reset(this)
            this.m_IsStageEmpty=true;
            this.m_StageDepth=0;
            this.m_Counter=zeros(4,1);

            this.m_CurrentStageMap=[];
        end

        function setTabName(this,aTabName)
            this.m_TabName=aTabName;
            Simulink.dv.SetTabName(aTabName);
        end

        function incrementStageDepth(this)

            if isequal(0,this.m_StageDepth)
                this.reset();
                this.updateStatusBar('');
            end

            this.m_StageDepth=this.m_StageDepth+1;

            this.addStage();
        end

        function decrementStageDepth(this)
            this.m_StageDepth=this.m_StageDepth-1;

            this.removeStage();

            if isequal(0,this.m_StageDepth)
                iNumErrors=this.m_Counter(slmsgviewer.m_ErrorSeverity);
                iNumWarnings=this.m_Counter(slmsgviewer.m_WarnSeverity)+this.m_Counter(slmsgviewer.m_HighPriorityWarning);
                iNumInfos=this.m_Counter(slmsgviewer.m_InfoSeverity);

                if(0~=iNumErrors)
                    if(1==iNumErrors)
                        this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_ONEERROR',iNumErrors));
                    else
                        this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_NERRORS',iNumErrors));
                    end
                elseif(0~=iNumWarnings)
                    if(1==iNumWarnings)
                        this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_ONEWARNING',iNumWarnings));
                    else
                        this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_NWARNINGS',iNumWarnings));
                    end
                elseif(0~=iNumInfos)
                    this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_VIEWDIAGNOSTICS'));
                end

                this.m_IsStageEmpty=true;
                this.m_Counter=zeros(4,1);
            end
        end

        function incrementRecordCount(this,iSeverity)
            if this.m_IsStageEmpty
                this.updateStatusBar(DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_VIEWDIAGNOSTICS'));
                this.m_IsStageEmpty=false;
            end

            this.m_Counter(iSeverity)=this.m_Counter(iSeverity)+1;
        end

        function updateStatusBar(this,aStatusBarMsg)
            Simulink.dv.UpdateStatusBar(this.m_TabName,aStatusBarMsg);
        end

        function addStage(this)
            this.m_StageCounter=this.m_MsgViewer.getStageSequence();

            aStageMap=Simulink.messageviewer.internal.MsgIdToDataMap(this.m_StageCounter);
            this.m_StageMap(this.m_StageCounter)=aStageMap;
            this.m_CurrentStageMap{end+1}=aStageMap;
        end

        function removeStage(this)
            aStageMap=this.getCurrentStageMap();
            if~isempty(aStageMap)











                this.m_CurrentStageMap(end)=[];
            end
        end

        function clearStage(this,iStageId)
            if(isKey(this.m_StageMap,iStageId))
                remove(this.m_StageMap,iStageId);
            end
        end

        function iCurrentStageId=getCurrentStageId(this)
            iCurrentStageId=this.m_StageCounter;
        end

        function iTabId=getId(this)
            iTabId=this.m_Id;
        end

        function[aCurrentStageMap]=getCurrentStageMap(this)
            if isempty(this.m_CurrentStageMap)
                aCurrentStageMap=[];
            else
                aCurrentStageMap=this.m_CurrentStageMap{end};
            end
        end

        function iNumSimilarRecordCount=pushMsgInMap(this,aMsgId,aRecord)
            iNumSimilarRecordCount=1;

            if isempty(aMsgId)
                return;
            end

            aCurrentStageMap=this.getCurrentStageMap();
            if~isempty(aCurrentStageMap)
                iNumSimilarRecordCount=aCurrentStageMap.addRecord(aMsgId,aRecord);
            end
        end

        function aKeySet=getKeysInMap(this)
            aKeySet={};

            aCurrentStageMap=this.getCurrentStageMap();
            if~isempty(aCurrentStageMap)
                aKeySet=aCurrentStageMap.getKeys();
            end
        end

        function iCount=getCountGivenMsgId(this,aMsgId)
            iCount=0;

            aCurrentStageMap=this.getCurrentStageMap();
            if~isempty(aCurrentStageMap)

                iCount=length(aCurrentStageMap.getRecords(aMsgId))-1;
            end
        end

        function aKeySet=getKeysGivenStageId(this,iStageId)
            aKeySet={};

            try
                aStageMap=this.m_StageMap(iStageId);
            catch
                return;
            end

            if~isempty(aStageMap)
                aKeySet=aStageMap.getKeys();
            end
        end

        function aRecords=getRecordsGivenMsgId(this,iStageId,aMsgId)
            aRecords=[];

            aStageMap=this.m_StageMap(iStageId);
            if~isempty(aStageMap)
                aRecords=aStageMap.getRecords(aMsgId);
            end
        end

        function clearOnlyGivenMsgId(this,iStageId,aMsgId)
            aStageMap=this.m_StageMap(iStageId);
            if~isempty(aStageMap)
                aStageMap.clearGivenMsgId(aMsgId);
            end
        end

    end

    properties
        m_TabName;
        m_Id;


        m_MsgViewer;

        m_StageDepth;
        m_IsStageEmpty;
        m_Counter;

        m_StageCounter;
        m_StageMap;
        m_CurrentStageMap;
    end
end
