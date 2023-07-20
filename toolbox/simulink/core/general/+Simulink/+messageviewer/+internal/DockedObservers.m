classdef DockedObservers<handle

    properties(Hidden)
        m_DockedObserversList;
    end


    methods(Access='public',Hidden=true)

        function obj=DockedObservers()
            obj.m_DockedObserversList=Simulink.messageviewer.internal.MsgViewer.empty(0,0);
        end

        function register(this,aObserver)
            this.m_DockedObserversList(end+1)=aObserver;
        end

        function bIsRegistered=isRegistered(this,aModelName)
            bIsRegistered=false;
            for idx=1:length(this.m_DockedObserversList)
                if strcmp(this.m_DockedObserversList(idx).m_ModelName,aModelName)
                    bIsRegistered=true;
                end
            end
        end

        function deregister(this,aObserverId)
            aSLMsgViewer=[];
            for idx=1:length(this.m_DockedObserversList)
                if strcmp(this.m_DockedObserversList(idx).m_ComponentId,aObserverId)
                    aSLMsgViewer=this.m_DockedObserversList(idx);
                    break;
                end
            end
            if~isempty(aSLMsgViewer)
                aSLMsgViewer.reset();
                this.m_DockedObserversList(idx)=[];
            end
        end

        function aResult=canProcess(this,aKey)
            aResult=Simulink.messageviewer.internal.MsgViewer.empty(0x0);
            for idx=1:length(this.m_DockedObserversList)
                if this.m_DockedObserversList(idx).canProcess(aKey)
                    aResult(end+1)=this.m_DockedObserversList(idx);%#ok<AGROW>
                end
            end
        end

    end

end


