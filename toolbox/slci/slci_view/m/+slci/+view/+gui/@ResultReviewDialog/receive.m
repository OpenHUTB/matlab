



function receive(obj,msg)
    try
        switch(msg.msgID)
        case 'blockRowSelect'
            obj.onBlockRowSelect(msg.data);
        case 'codeSliceRowSelect'
            obj.onCodeSliceRowSelect(msg.data);
        case 'ready'
            obj.reloadData();
        case 'refresh'
            obj.reloadData();
        case 'interfaceRowSelect'
            obj.onInterfaceRowSelect(msg.data);
        case 'tempVarRowSelect'
            obj.onTempVarRowSelect(msg.data);
        case 'utilRowSelect'
            obj.onUtilFuncRowSelect(msg.data);
        case 'getJustificationForSID'
            obj.getJustificationForSid(msg.data);
        case 'addNewJustificationInJson'
            obj.addNewJustificationInJson(msg.data);
        case 'updateJustificationComentInJson'
            obj.updateJustificationJson(msg.data);
        case 'deleteJustificationCommentFromJson'
            obj.deleteJustificationCommentFromJson(msg.data);
        case 'getJustificationForCode'
            obj.getJustificationForCodeLines(msg.data);
        case 'deleteAllJustificationComments'
            obj.deleteAllJustificationComments(msg.data);
        otherwise
        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end