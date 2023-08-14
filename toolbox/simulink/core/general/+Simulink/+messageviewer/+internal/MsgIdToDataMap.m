classdef MsgIdToDataMap<handle

    methods
        function obj=MsgIdToDataMap(iStageId)
            obj.m_StageId=iStageId;
            obj.m_MapStore=containers.Map();
        end

        function iStageId=getStageId(this)
            iStageId=this.m_StageId;
        end

        function iNumRecords=addRecord(this,aMsgId,aRecord)


            if(isKey(this.m_MapStore,aMsgId))
                aMapData=this.m_MapStore(aMsgId);
            else
                aMapData=Simulink.messageviewer.internal.MsgMapData();
                this.m_MapStore(aMsgId)=aMapData;
            end

            aMapData.add(aRecord);

            iNumRecords=aMapData.size();
        end

        function aRecords=getRecords(this,aMsgId)
            try
                aRecords=this.m_MapStore(aMsgId).getRecords();
            catch
                aRecords=[];
            end
        end

        function clearGivenMsgId(this,aMsgId)
            remove(this.m_MapStore,aMsgId);
        end

        function aKeySet=getKeys(this)
            aKeySet=keys(this.m_MapStore);
        end
    end

    properties(Access=private)
m_StageId
m_MapStore
    end
end

