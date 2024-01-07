function deliverInfoNotification(block,msgid,varargin)
    editor=GLUE2.Util.findAllEditors(block);
    while isempty(editor)&&~isempty(block)
        block=get_param(block,'Parent');
        editor=GLUE2.Util.findAllEditors(block);
    end
    if~isempty(editor)
        msg=MSLDiagnostic(message(msgid,varargin{:})).message;
        editor.deliverInfoNotification(msgid,msg);
    end
end