

classdef RTCRequestDispatcher<handle
    properties(Access=protected)

        m_tagToHandler=[];
    end

    methods(Access=public)
        function obj=RTCRequestDispatcher()
            obj.m_tagToHandler=containers.Map();
        end

        function requestHandler=getHandler(this,tag)
            requestHandler=this.m_tagToHandler(tag);
        end

        function registerHandler(this,tag,requestHandler)
            this.m_tagToHandler(tag)=requestHandler;
        end

        function unRegisterHandler(this,tag)
            remove(this.m_tagToHandler,tag);
        end
    end
end
