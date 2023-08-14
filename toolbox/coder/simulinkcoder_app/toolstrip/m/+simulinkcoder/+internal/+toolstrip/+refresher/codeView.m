function codeView(cbinfo,action)


    isERTTarget=strcmp(get_param(cbinfo.model.handle,'IsERTTarget'),'on');
    action.enabled=isERTTarget;
end