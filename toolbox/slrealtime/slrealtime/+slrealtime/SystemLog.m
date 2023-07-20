classdef SystemLog<handle




    properties(Access=private)
logs
    end

    properties(Dependent)
severityFilter
messageFilter
    end

    methods
        function value=get.messageFilter(obj)
            value=obj.logs.messageFilter;
        end

        function value=get.severityFilter(obj)
            value=obj.logs.severityFilter;
        end

        function set.messageFilter(obj,value)
            obj.logs.messageFilter=value;
        end

        function set.severityFilter(obj,value)
            obj.logs.severityFilter=value;
        end
    end

    methods(Access=public)
        function obj=SystemLog(tg)


            obj.logs=slrealtime.internal.systemlog.Logs();
            if~isempty(tg)
                obj.reset(tg);
            end
        end

        function result=tail(obj,nlines)

            result=obj.logs.tail(nlines);
        end

        function result=messages(obj)

            result=obj.logs.messages;
        end

        function append(obj,system_log_messages)
            obj.logs.merge(convertCharsToStrings(system_log_messages));
        end

        function reset(obj,tg)
            command=['ls ',tg.HomeDir,'/logs'];
            out=tg.executeCommand(command);
            lognames=convertCharsToStrings(out.Output).split();
            lognames=lognames(lognames~="");
            lognames=lognames(lognames~="logd.log");
            for ii=length(lognames):-1:1
                logfile=sprintf('%s/logs/%s',tg.HomeDir,lognames(ii));
                if~tg.isfile(logfile)
                    continue;
                end
                data=getLogData(tg,logfile);
                obj.logs.merge(data);
            end
        end
    end
end

function result=getLogData(tg,logfile)

    cmd=sprintf('cat %s',logfile);
    out=tg.executeCommand(cmd);
    data=convertCharsToStrings(out.Output);
    result=data.splitlines();
end
