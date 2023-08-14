function addCallbackImpl(obj,type,id,fcn)














    assert(ismember(type,{'PreLoad','PostLoad',...
    'PreSave','PostSave',...
    'PostNameChange',...
    'PreShow','PreClose',...
    'PreDestroy','CloseRequest',...
    'Test'}));
    assert(isvarname(id),'ID must be a valid variable name');
    assert(isa(fcn,'function_handle'));

    callbacks=get_param(obj.Handle,'Callbacks');
    assert(isempty(callbacks)||isstruct(callbacks));
    if isfield(callbacks,type)
        f=callbacks.(type);
    else
        f=struct;
    end
    if isfield(f,id)
        DAStudio.error('Simulink:utility:BlockDiagramCallbackAlreadyPresent',...
        type,id,obj.Name);
    end
    f.(id)=fcn;
    callbacks.(type)=f;
    set_param(obj.Handle,'Callbacks',callbacks);

    if strcmp(type,'PreShow')&&strcmp(obj.Open,'on')
        try
            fcn();
        catch E
            MSLDiagnostic('Simulink:utility:BlockDiagramExecutionError',...
            type,id,obj.Name,E.message).reportAsWarning;
        end
    end

end
