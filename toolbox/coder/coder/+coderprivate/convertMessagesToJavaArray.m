



function messages=convertMessagesToJavaArray(report,messageListOverride)
    messages=[];

    hasMessageListOverride=nargin>1;

    if hasMessageListOverride
        messageList=messageListOverride;
    elseif isfield(report,'summary')&&isfield(report.summary,'coderMessages')
        messageList=report.summary.coderMessages;
    else
        messageList=[];
    end

    if~isempty(messageList)
        fcns=[];
        if~isempty(report.inference)&&isprop(report.inference,'Functions')
            fcns=report.inference.Functions;
        end
        messages=emlcprivate('flattenMessagesForJava',messageList,report.scripts,[],fcns);
    end



    if~hasMessageListOverride&&isfield(report,'inference')&&~isempty(report.inference)
        for i=1:numel(report.inference.Functions)
            fcn=report.inference.Functions(i);
            if numel(fcn.Messages)>0
                messages=[messages,emlcprivate('flattenMessagesForJava',...
                fcn.Messages,...
                report.inference.Scripts,...
                struct('FunctionID',i,'ScriptID',fcn.ScriptID),...
                report.inference.Functions...
                )];%#ok<AGROW>
            end
        end
    end

end