function constructUI(ui,idx)































    [selection,ok]=listdlg('ListString',ui(idx).menuitems,...
    'SelectionMode','single',...
    'Name',ui(idx).name,...
    'PromptString',ui(idx).prompt,...
    'ListSize',ui(idx).size);

    if ok
        processCallback(ui,idx,selection);
    end
end



function processCallback(ui,idx,selection)





    cb=ui(idx).callbacks{selection};
    cbtype=getCallbackIDType(cb);
    switch cbtype
    case 'integer'
        if cb>0&&cb<=length(ui)
            linkfoundation.util.constructUI(ui,cb);
        else
            DAStudio.error('ERRORHANDLER:utils:CallbackIdOutOfRange',num2str(cb),num2str(length(ui)));
        end
    case 'string'
        try
            eval(cb);
        catch ME
            DAStudio.error('ERRORHANDLER:utils:CannotEvaluateCallback',ME.message);
        end
    case 'unsupported'
        DAStudio.error('ERRORHANDLER:utils:InvalidCallbackIdType',class(cb));
    end
end


function cbtype=getCallbackIDType(cb)


    cbtype='unsupported';

    if isnumeric(cb)
        if cb-int32(cb)==0
            cbtype='integer';
        end
    elseif ischar(cb)
        cbtype='string';
    end
end