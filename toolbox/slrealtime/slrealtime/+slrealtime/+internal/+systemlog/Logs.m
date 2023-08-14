classdef Logs<handle




    properties(Access=private)
logmessages

    end

    properties(Access=public)
severityFilter
messageFilter
    end

    methods
        function obj=Logs(varargin)
            p=inputParser;
            addOptional(p,"data","",@isstring);
            p.parse(varargin{:});
            obj.logmessages=logDataToTable(p.Results.data);

            obj.severityFilter="";
            obj.messageFilter="";
        end

        function merge(obj,newdata)


            obj.append(newdata);
            if~isempty(obj.logmessages)
                obj.logmessages=sortrows(obj.logmessages,1);
            end
        end

        function append(obj,newdata)

            newmessages=logDataToTable(newdata);
            obj.logmessages=[obj.logmessages;newmessages];
        end

        function result=tail(obj,nlines)

            msgs=obj.messages;
            startrow=size(msgs,1)-(nlines-1);
            if(startrow<1)
                warning("Cannot get last %d lines of system log.",nlines);
                return;
            end
            result=msgs(startrow:end,:);
        end

        function result=messages(obj)

            result=obj.logmessages;
            if strlength(obj.messageFilter)>0
                indexes=contains(result.Message,obj.messageFilter,"IgnoreCase",true);
                result=result(indexes,:);
            end

            if strlength(obj.severityFilter)>0&&obj.severityFilter~="all"
                indexes=contains(result.Severity,obj.severityFilter,"IgnoreCase",true);
                result=result(indexes,:);
            end
        end

        function result=logsize(obj)
            result=size(obj.logmessages,1);
        end

    end
end

function result=dataToLogArray(data)


    data=convertCharsToStrings(data);
    data=data.splitlines().strip();
    indexes=0<data.strlength();
    result=data(indexes);
end

function result=parseSLRTApplicationLog(loglines)
    date_re="(\d{4}-\d{2}-\d{2})";
    time_re=" (\d{2}:\d{2}:\d{2}(.\d+)?)";
    categry_re=" \[(\d+)\s*\]";
    severity_re=" \[(\w+)\s*]";
    message_re=" (.*$)";

    tokens=regexp(loglines,...
    date_re+time_re+categry_re+severity_re+message_re,...
    "tokens");
    if isempty(tokens)
        result=[];
        return;
    end


    idxs=find(cellfun(@isempty,tokens));
    if~isempty(idxs)
        for i=numel(idxs):-1:1
            nIdx=idxs(i);
            if nIdx==1,break;end
            if~isempty(loglines{nIdx})
                loglines{nIdx-1}=[loglines{nIdx-1},' ',loglines{nIdx}];
            end
        end


        tokens=regexp(loglines,...
        date_re+time_re+categry_re+severity_re+message_re,...
        "tokens");
        if isempty(tokens)
            result=[];
            return;
        end
    end

    tokens=tokens(~cellfun(@isempty,tokens));
    if isempty(tokens)
        result=[];
        return;
    end

    x=[tokens{:}];
    if length(loglines)>1
        result=vertcat(x{:});
    else
        result=x;
    end
end

function result=logArrayToLogMatrix(loglines)




    parsed=parseSLRTApplicationLog(loglines);
    if~isempty(parsed)
        result=parsed;
        return;
    end

    h=length(loglines);
    result(1:h,1)="";
    result(1:h,2)="";
    result(1:h,3)="0";
    result(1:h,4)="info";
    result(1:h,5)=loglines(:);
end

function result=logDataToTable(data)


    logarray=dataToLogArray(data);
    logarray=logarray(strlength(logarray)>0);
    logmatrix=logArrayToLogMatrix(logarray);

    if isempty(logmatrix)
        result=table.empty;
        return;
    end

    dt=datetime(logmatrix(:,1:2).join(" "));
    dt.Format='dd-MM-uuuu HH:mm:ss.SSSSSSSSS';
    cat=str2double(logmatrix(:,3));
    msg=logmatrix(:,5);
    sev=logmatrix(:,4);

    result=table(dt,msg,sev,cat,...
    'VariableNames',["Timestamp","Message","Severity","Category"]);

end
