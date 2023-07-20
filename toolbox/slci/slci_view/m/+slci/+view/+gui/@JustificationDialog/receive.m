



function receive(obj,msg)
    try
        switch(msg.msgID)
        case 'ready'
            obj.reloadData();
        case 'refresh'
            obj.reloadData();
        case 'fetchSelectedBlockSID'
            obj.fetchSelectedBlockSID();
        case 'verifyInputCodeLines'
            obj.verifyInputCodeLines(msg.data);
        case 'verifyInputBlockSID'
            obj.verifyInputBlockSID(msg.data);
        otherwise
        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end
