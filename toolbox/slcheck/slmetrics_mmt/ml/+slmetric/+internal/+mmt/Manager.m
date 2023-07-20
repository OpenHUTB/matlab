classdef Manager<handle


    properties(Access=private)
        ExplorerSessions;
        SessionShutdownSubscription;
    end

    methods
        function register(this,expl)
            this.ExplorerSessions(expl.ID)=expl;

        end

        function unregister(this,id)
            if this.ExplorerSessions.isKey(id)
                this.ExplorerSessions.remove(id);

            end
        end

        function clear(this)
            this.ExplorerSessions=containers.Map();
        end

        function ids=getRegisteredExplorerSessionIDs(this)
            ids=this.ExplorerSessions.keys;
        end


        function expl=getExplorerByID(this,id)
            expl=slmetric.Explorer.empty();
            if this.ExplorerSessions.isKey(id)
                expl=this.ExplorerSessions(id);
            end
        end


        function status=checkExplorerBySystemAndType(this,system,type)
            expId=this.getRegisteredExplorerSessionIDs();
            if(~isempty(expId))
                for index=1:numel(expId)
                    if((strcmp(this.getExplorerByID(expId{index}).model,system))&&(strcmp(this.getExplorerByID(expId{index}).type,type)))
                        status=0;
                        break;
                    end
                    status=1;
                end
            else
                status=1;
            end
        end
    end

    methods(Access=private)
        function this=Manager()
            this.ExplorerSessions=containers.Map();
            this.SessionShutdownSubscription=...
            message.subscribe('/slmetric/c2s_Shutdown',@(msg)handleSessionShutdown(this,msg));
        end

        function handleSessionShutdown(this,data)
            if isfield(data,'Message')&&...
                strcmp(data.Message,'SessionShutdown')&&...
                isfield(data,'SessionID')
                this.unregister(data.SessionID)
            end
        end
    end

    methods(Static)
        function inst=get()
            mlock;
            persistent Inst;

            if isempty(Inst)
                Inst=slmetric.internal.mmt.Manager();
            end

            inst=Inst;
        end
    end

end

