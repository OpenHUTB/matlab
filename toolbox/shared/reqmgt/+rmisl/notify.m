function notify(modelH,msgObj,varargin)

    if(nargin<2||isempty(msgObj))

        postHTML(modelH,'');
        return;
    end

    actionHTML='';

    for idx=1:(nargin-2)
        cbObj=varargin{idx};
        cbFcnMethod=fliplr(strtok(fliplr(cbObj.Identifier),':'));
        modelName=get_param(modelH,'Name');
        linkText=cbObj.getString();
        linkStr=...
        sprintf(' <A href="matlab:rmisl.notifycb(''%s'',''%s'')">%s</A> ',...
        cbFcnMethod,modelName,linkText);

        if idx==1
            actionHTML=linkStr;
        else
            actionHTML=[actionHTML,', ',linkStr];%#ok<AGROW>
        end
    end

    htmlStr=[msgObj.getString(),actionHTML];
    postHTML(modelH,htmlStr);
end


function postHTML(modelH,htmlStr)
    edtrs=rmisl.modelEditors(modelH);
    msgId='SlRQ:Studio:Info';

    for idx=1:numel(edtrs)
        ed=edtrs(idx);

        ed.closeNotificationByMsgID(msgId);

        if~isempty(htmlStr)
            ed.deliverInfoNotification(msgId,htmlStr);
        end
    end
end



