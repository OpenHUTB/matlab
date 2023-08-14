



function[messages]=flattenMessagesForJava(messageList,scripts,fcnData,fcnInfos)
    messages=[];

    isScriptsObjectArray=isobject(scripts);
    isMesssagesCellArray=iscell(messageList);
    isInferMessage=~isMesssagesCellArray&&nargin>2&&...
    isa(messageList,'eml.InferMessage');

    for i=1:numel(messageList)
        if isMesssagesCellArray
            message=messageList{i};
        else
            message=messageList(i);
        end

        if isInferMessage
            scriptId=fcnData.ScriptID;
        elseif~isempty(fcnInfos)
            scriptId=fcnInfos(message.FunctionID).ScriptID;
        else
            scriptId=message.ScriptID;
        end

        if scriptId>0
            if isScriptsObjectArray
                s=scripts(scriptId);
            else
                s=scripts{scriptId};
            end

            messages(i).functionName=s.ScriptName;%#ok<*AGROW>
            messages(i).file=s.ScriptPath;
        else
            messages(i).functionName='';
            messages(i).file='';
        end

        messages(i).type=message.MsgTypeName;
        messages(i).position=message.TextStart;
        messages(i).length=message.TextLength;
        messages(i).id=message.MsgID;
        messages(i).specializationName='';

        if isInferMessage
            messages(i).functionId=fcnData.FunctionID;
            messages(i).ordinal=message.Ordinal;
        else
            messages(i).functionId=message.FunctionID;
            messages(i).ordinal=-1;
        end


        infoLink=coder.internal.moreinfo(message.MsgID);
        if~isempty(infoLink)
            messages(i).text=[message.MsgText,' ',infoLink];
        else
            messages(i).text=message.MsgText;
        end
    end
end