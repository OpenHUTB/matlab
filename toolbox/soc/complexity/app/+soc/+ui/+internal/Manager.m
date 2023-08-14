classdef Manager<handle


    properties(Access=private)
        AppSessions;
    end

    methods
        function register(this,hreport)
            this.AppSessions(hreport.ID)=hreport;
        end

        function unregister(this,id)
            if this.AppSessions.isKey(id)
                this.AppSessions.remove(id);

            end
        end

        function delete(this)
            windows=matlab.internal.webwindowmanager.instance();
            result=windows.findAllWebwindows;


            for i=1:length(result)

                if(strcmp(result(i).Title,'Algorithm Analyzer Results'))
                    result(i).close();
                end

            end
            this.AppSessions=containers.Map();
        end

        function ids=getRegisteredExplorerSessionIDs(this)
            ids=this.AppSessions.keys;
        end


        function hreport=getReportByID(this,id)
            hreport=soc.ui.HTMLReport.empty();
            if this.AppSessions.isKey(id)
                hreport=this.AppSessions(id);
            end
        end

    end

    methods(Access=private)
        function this=Manager()
            this.AppSessions=containers.Map();
        end
    end

    methods(Static)
        function inst=get()

            persistent Inst;

            if isempty(Inst)
                Inst=soc.ui.internal.Manager();
            end

            inst=Inst;
        end
    end

end

