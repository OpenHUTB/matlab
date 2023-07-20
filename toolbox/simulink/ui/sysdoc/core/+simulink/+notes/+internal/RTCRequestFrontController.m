

classdef RTCRequestFrontController<handle
    properties(Access=protected)

        m_dispatcher=[];
        m_registerHelper=[];
    end

    methods(Access=public)
        function obj=RTCRequestFrontController()
            import simulink.notes.internal.RTCRequestDispatcher;
            obj.m_dispatcher=RTCRequestDispatcher();
        end

        function rtcContent=onRTCEditorLoaded(this,tag)
            rtcContent=[];
            requestHandler=this.getHandler(tag);
            if isempty(requestHandler)
                return;
            end
            rtcContent=requestHandler.onRTCEditorLoaded();
        end

        function donePingPong=getDonePingPong(this,tag)
            donePingPong=false;
            requestHandler=this.getHandler(tag);
            if isempty(requestHandler)
                return;
            end
            donePingPong=requestHandler.getDonePingPong();
        end

        function dispatcher=getDispatcher(this)
            dispatcher=this.m_dispatcher;
        end
    end

    methods(Access={?simulink.sysdoc.internal.JSClientRTCProxy,?sysdoc.NotesTester,?SysDocTestInterface})


        function setDonePingPong(this,value,tag)
            requestHandler=this.getHandler(tag);
            if isempty(requestHandler)
                return;
            end
            requestHandler.setDonePingPong(value);
        end

        function studioTag=requestHandlerTestCallback(this,tag)
            studioTag='testEmpty';
            requestHandler=this.getHandler(tag);
            if isempty(requestHandler)
                return;
            end
            studioTag=requestHandler.requestHandlerTestCallback();
        end
    end

    methods(Access=protected)
        function requestHandler=getHandler(this,tag)
            requestHandler=this.m_dispatcher.getHandler(tag);
        end
    end
end
