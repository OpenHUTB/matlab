


function receive(obj,msg)
    try
        switch(msg.msgID)
        case 'ready'
            obj.reloadData();
        case 'updateData'
            obj.updateData(msg.data);
        case 'deleteData'
            obj.deleteData(msg.codeLanguage,msg.data);
        case 'rowSelected'
            obj.onRowSelected(msg.codeLanguage,msg.data);
        otherwise
            disp(msg);
        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end