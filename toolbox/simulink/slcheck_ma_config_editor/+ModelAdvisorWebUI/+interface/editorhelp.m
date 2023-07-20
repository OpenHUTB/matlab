function resultJSON=editorhelp(CSHParameters)





    try
        if~isempty(CSHParameters)
            if isfield(CSHParameters,'MapKey')&&...
                isfield(CSHParameters,'TopicID')
                mapkey=['mapkey:',CSHParameters.MapKey];
                topicid=CSHParameters.TopicID;
















                helpview(mapkey,topicid,'CSHelpWindow');
            end
        end
    catch
    end

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','');
    resultJSON=jsonencode(result);

end
