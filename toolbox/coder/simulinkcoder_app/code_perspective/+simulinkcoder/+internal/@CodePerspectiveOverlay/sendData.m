function sendData(obj,msg)


    if strcmp(msg,'start')
        data.bg=obj.export();
        data.fg=obj.fg;
        message.publish(['/',obj.channel],data);

        dlg=obj.dlg;
        if isa(dlg,'DAStudio.Dialog')
            dlg.show;
        end
    elseif strcmp(msg,'exit')
        dlg=obj.dlg;
        if isa(dlg,'DAStudio.Dialog')
            delete(dlg);
        end
    end