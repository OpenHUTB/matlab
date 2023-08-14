


function receive(obj,msg)
    try
        switch(msg.msgID)
        case 'ready'
            obj.reloadData();
        case 'reloadData'
            obj.reloadData(msg.modelName,msg.msgID);
        case 'onFileChange'
            obj.reloadData(msg.modelName,msg.msgID);
        otherwise
            disp(msg);
        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end