function schema=contextMenuSelectiveLogging(callbackInfo)
    schema=sl_toggle_schema;
    schema.label=getString(message('physmod:simscape:simscape:menus:LogSimulationData'));
    schema.tag='Simscape:SelectiveLogging';
    schema.callback=@lSelectiveLoggingCallback;
    schema.state='Hidden';
    if(numel(callbackInfo.getSelection)==1)&&...
        lIsLoggingSupported(callbackInfo.getSelection.Handle)
        if lIsInLockedLibrary(callbackInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
        if strcmpi('on',get_param(callbackInfo.getSelection.Handle,...
            'LogSimulationData'))
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end

    end
end

function lSelectiveLoggingCallback(callbackInfo)
    block=callbackInfo.getSelection.Handle;
    status=get_param(block,'LogSimulationData');
    if strcmpi(status,'on')
        set_param(block,'LogSimulationData','off');
    else
        set_param(block,'LogSimulationData','on');
    end
end


function result=lIsLoggingSupported(block)

    result=pmlog_is_logging_supported(block);
end

function result=lIsInLockedLibrary(block)
    rootModel=bdroot(block);
    result=bdIsLibrary(rootModel)&&...
    strcmp(get_param(rootModel,'Lock'),'on');
end
