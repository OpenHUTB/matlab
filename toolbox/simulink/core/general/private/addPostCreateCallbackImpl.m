function addPostCreateCallbackImpl(~,id,fcn)













    callbacks=get_param(0,'RootCallbacks');
    assert(isempty(callbacks)||isstruct(callbacks));
    if isfield(callbacks,id)
        DAStudio.error('Simulink:utility:RootCallbackAlreadyPresent',...
        'PostCreate',id);
    end
    callbacks.(id)=fcn;
    set_param(0,'RootCallbacks',callbacks);

end
