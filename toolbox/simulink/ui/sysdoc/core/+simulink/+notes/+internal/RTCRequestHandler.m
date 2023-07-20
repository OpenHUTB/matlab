

classdef(Abstract)RTCRequestHandler<handle

    properties(Access=protected)
        m_donePingPong=false;


        m_dispatcher=[];
        m_studioTag=[];
    end

    methods(Access=public)
        function obj=RTCRequestHandler(studioTag,dispatcher)
            obj.m_donePingPong=false;


            dispatcher.registerHandler(studioTag,obj);
            obj.m_dispatcher=dispatcher;
            obj.m_studioTag=studioTag;
        end

        function unRegisterHandler(obj)
            if~isempty(obj.m_dispatcher)
                obj.m_dispatcher.unRegisterHandler(obj.m_studioTag);
                obj.m_dispatcher=[];
                obj.m_studioTag=[];
            end
        end

        function donePingPong=getDonePingPong(this)
            donePingPong=this.m_donePingPong;
        end
    end

    methods(Abstract,Access=public)
        rtcContent=onRTCEditorLoaded(this);
    end

    methods(Access={?simulink.notes.internal.RTCRequestHandler,?simulink.notes.internal.RTCRequestFrontController,?sysdoc.NotesTester,?SysDocTestInterface})


        function studioTag=requestHandlerTestCallback(this)
            studioTag='test';
        end
    end

    methods(Access={?simulink.notes.internal.RTCRequestHandler,?simulink.notes.internal.RTCRequestFrontController,?sysdoc.NotesTester,?SysDocTestInterface})


        function setDonePingPong(this,value)
            this.m_donePingPong=value;
        end
    end
end
