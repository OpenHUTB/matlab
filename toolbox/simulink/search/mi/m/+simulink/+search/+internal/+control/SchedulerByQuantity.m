


classdef SchedulerByQuantity<handle

    methods(Access=public)
        function obj=SchedulerByQuantity(idealPublishTimes,maxRecordPerPublish,totalyNumber)

            import simulink.search.internal.model.ReplacedInfoManager;
            import simulink.search.internal.model.ErrorManager;
            obj.m_recordPerPublish=ceil(totalyNumber/idealPublishTimes);
            obj.m_recordPerPublish=min(obj.m_recordPerPublish,maxRecordPerPublish);
            obj.m_recordCount=0;
            obj.m_publishCallback=[];
        end

        function addRecord(this,count)
            this.m_recordCount=this.m_recordCount+count;
            if(this.m_recordCount>=this.m_recordPerPublish)
                this.m_publishCallback();
                this.m_recordCount=0;
            end
        end

        function setPublishCallback(this,publishCallback)
            this.m_publishCallback=publishCallback;
        end
    end

    properties(Access=protected)
        m_recordPerPublish=0;
        m_recordCount=0;
        m_publishCallback=[];
    end
end
