function tf=isEditor(cbinfo)


    if strcmp(class(cbinfo),'dig.CallbackInfo')
        tf=true;
    else

        tf=false;
    end
end