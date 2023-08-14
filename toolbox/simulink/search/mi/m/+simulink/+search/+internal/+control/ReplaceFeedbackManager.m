





classdef ReplaceFeedbackManager<handle

    methods(Access=public)
        function obj=ReplaceFeedbackManager(scheduler,channel,messageType)

            import simulink.search.internal.model.ReplacedInfoManager;
            import simulink.search.internal.model.ErrorManager;
            obj.m_replacedInfo=ReplacedInfoManager();
            obj.m_errorManager=ErrorManager();

            obj.m_feedbackScheduler=scheduler;
            obj.m_feedbackScheduler.setPublishCallback(@()obj.flush);

            obj.m_channel=channel;
            obj.m_messageType=messageType;
        end

        function replaceInfoManager=getReplaceInfoManager(this)
            replaceInfoManager=this.m_replacedInfo;
        end

        function errorManager=getErrorManager(this)
            errorManager=this.m_errorManager;
        end

        function reset(this)
            this.m_replacedInfo.reset();
            this.m_errorManager.reset();
        end

        function addReplacedInfo(this,propertyId,propertyData)
            this.m_replacedInfo.addReplacedInfo(propertyId,propertyData);
            this.m_feedbackScheduler.addRecord(1);
        end

        function addErrorInfo(this,timeStamp,blockUri,propId,errorMessage)
            this.m_errorManager.addErrorInfo(timeStamp,blockUri,propId,errorMessage);
            this.m_feedbackScheduler.addRecord(1);
        end

        function flush(this)
            total=numel(this.m_errorManager.errorInfos)+numel(this.m_replacedInfo.replacedInfos);
            if total==0
                return;
            end

            searchReplaceMsg=struct();
            searchReplaceMsg.type=this.m_messageType;
            searchReplaceMsg.args={this.m_replacedInfo,this.m_errorManager};
            message.publish(this.m_channel,searchReplaceMsg);
            this.reset();
        end
    end

    properties(Access=protected)
        m_replacedInfo=[];
        m_errorManager=[];
        m_feedbackScheduler=[];
        m_channel='';
        m_messageType='';
    end
end
